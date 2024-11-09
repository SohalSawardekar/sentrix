/**
 * Import function triggers from their respective submodules:
 *
 * const {onCall} = require("firebase-functions/v2/https");
 * const {onDocumentWritten} = require("firebase-functions/v2/firestore");
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

// Create and deploy your first functions
// https://firebase.google.com/docs/functions/get-started

// exports.helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
const functions = require('firebase-functions');
const { LanguageServiceClient } = require('@google-cloud/language');
const client = new LanguageServiceClient();

exports.analyzeSentiment = functions.https.onCall(async (data, context) => {
  const text = data.text;

  const document = {
    content: text,
    type: 'PLAIN_TEXT',
  };

  try {
    const [result] = await client.analyzeSentiment({ document });
    const sentiment = result.documentSentiment;
    return { score: sentiment.score, magnitude: sentiment.magnitude };
  } catch (error) {
    console.error('Error analyzing sentiment:', error);
    throw new functions.https.HttpsError('internal', 'Sentiment analysis failed');
  }
});
