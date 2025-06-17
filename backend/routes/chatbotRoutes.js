const express = require('express');
const router = express.Router();
const Property = require('../models/Property');
const fetch = require('node-fetch');

// Llama 2 integration endpoint
router.post('/llm', async (req, res) => {
  try {
    // Accept both message and propertyId from frontend
    const { message, propertyId, context = {} } = req.body;

    let property = null;
    let properties = [];
    let isDetail = false;

    // 1. If propertyId is provided (clicked from UI), fetch by ID
    if (propertyId) {
      property = await Property.findById(propertyId);
      isDetail = !!property;
    }

    // 2. If not, try to extract a property title from the message
    if (!isDetail && message) {
      const propertyMatch = message.match(/property\s+([a-zA-Z0-9\s]+)/i);
      if (propertyMatch) {
        property = await Property.findOne({ title: new RegExp(propertyMatch[1].trim(), 'i') });
        isDetail = !!property;
      }
    }

    // 3. If not detail, check for list intent
    if (!isDetail && message && /property|apartment|house|show|list/i.test(message)) {
      properties = await Property.find({}).limit(5);
    }

    // Compose prompt for Llama 2
    const systemPrompt = `
You are a helpful assistant for NES Properties. Only answer using the property and owner data provided below.
If the answer is not in the data, say: "Sorry, I can only answer questions about NES Properties listings and owners."
Property data: ${JSON.stringify(property ? [property] : properties)}
User: ${message || ''}${propertyId ? ` (propertyId: ${propertyId})` : ''}
`;

    // Call Llama 2 via Ollama
    const llmResponse = await fetch('http://localhost:11434/api/generate', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        model: 'llama2',
        prompt: systemPrompt,
        stream: false
      })
    }).then(r => r.json());

    // Return property-card if detail, property-list if list, text otherwise
    if (property) {
      res.json({
        type: 'property-card',
        property: property,
        content: 'Here are the details for this property...',
        suggestions: ['Contact owner', 'Show similar properties'],
        context: { ...context }
      });
    } else if (properties.length) {
      res.json({
        type: 'property-list',
        properties,
        content: llmResponse.response,
        suggestions: ['Show more', 'Filter by price', 'Contact owner'],
        context: { ...context }
      });
    } else {
      res.json({
        type: 'text',
        content: llmResponse.response,
        suggestions: [],
        context: { ...context }
      });
    }
  } catch (error) {
    res.status(500).json({
      type: 'text',
      content: 'Sorry, something went wrong. Please try again later.',
      suggestions: ['Try again', 'Contact support']
    });
  }
});

module.exports = router;
