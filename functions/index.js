const functions = require('firebase-functions');
const axios = require('axios');
const cors = require('cors')({ origin: true });

exports.getDistanceMatrix = functions.https.onRequest((req, res) => {
  cors(req, res, async () => {
    const { origin, destination } = req.query;

    const apiKey = 'AIzaSyDht7oI9XSbULKIf038hfwBBRs2OySzC2k';
    const url = `https://maps.googleapis.com/maps/api/distancematrix/json?origins=${origin}&destinations=${destination}&key=${apiKey}`;

    try {
      const response = await axios.get(url);
      res.status(200).send(response.data);
    } catch (error) {
      res.status(500).send({ error: error.toString() });
    }
  });
});
