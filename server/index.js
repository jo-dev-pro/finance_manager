const express = require('express');
const axios = require('axios');
require('dotenv').config();

const app = express();
app.use(express.json());

let cachedAccessToken = null;
let tokenExpiresAt = 0;

async function getTossAccessToken() {
  const now = Date.now();
  if (cachedAccessToken && now < tokenExpiresAt) {
    return cachedAccessToken;
  }

  // 하드코딩된 주소 대신 환경 변수를 사용하도록 수정
  const response = await axios.post(`${process.env.TOSS_API_BASE_URL}/oauth/token`, {
    grant_type: 'client_credentials',
    client_id: process.env.TOSS_CLIENT_ID,
    client_secret: process.env.TOSS_CLIENT_SECRET,
  });

  cachedAccessToken = response.data.access_token;
  tokenExpiresAt = now + (response.data.expires_in - 600) * 1000;
  return cachedAccessToken;
}

app.get('/api/account/balance', async (req, res) => {
  try {
    const accessToken = await getTossAccessToken();
    
    // 하드코딩된 주소 대신 환경 변수를 사용하도록 수정
    const tossResponse = await axios.get(`${process.env.TOSS_API_BASE_URL}/v1/trading/accounts/balance`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    
    res.json(tossResponse.data);
  } catch (error) {
    console.error('토스 API 호출 에러:', error.response?.data || error.message);
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Proxy server running on port ${PORT}`));