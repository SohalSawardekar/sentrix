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

const functions = require("firebase-functions");
const admin = require("firebase-admin");
const axios = require("axios");

admin.initializeApp();
const db = admin.firestore();

// Function to fetch and analyze news articles
exports.fetchAndAnalyzeNews = functions.pubsub.schedule("every 60 minutes").onRun(async (context) => {
  try {
    const stockSymbol = "AAPL";  // Or dynamically fetch symbols as needed
    const newsApiKey = functions.config().newsapi.key;
    const textRazorKey = functions.config().textrazor.key;

    // Fetch news data from a news API
    const newsResponse = await axios.get("https://newsapi.org/v2/everything", {
      params: {
        q: stockSymbol,
        sortBy: "publishedAt",
        apiKey: newsApiKey,
      },
    });

    const articles = newsResponse.data.articles;

    // Analyze each article with TextRazor
    for (const article of articles) {
      const textRazorResponse = await axios.post(
        "https://api.textrazor.com/",
        `text=${encodeURIComponent(article.description || article.content)}`,
        {
          headers: {
            "x-textrazor-key": textRazorKey,
            "Content-Type": "application/x-www-form-urlencoded",
          },
          params: {
            extractors: "entities,topics,sentiment",
          },
        }
      );

      const analysis = textRazorResponse.data.response;
      const sentiment = analysis.sentiment || 0;
      const entities = analysis.entities || [];

      // Store analysis results in Firestore
      const stockRef = db.collection("stocks").doc(stockSymbol);
      const newsCollection = stockRef.collection("news");
      await newsCollection.add({
        title: article.title,
        url: article.url,
        publishedAt: article.publishedAt,
        source: article.source.name,
        sentiment: sentiment,
        entities: entities.map(entity => entity.entityId), // Stores relevant entities
      });
    }

    console.log("News articles analyzed and stored successfully.");
  } catch (error) {
    console.error("Error fetching or analyzing news data:", error);
  }
});

