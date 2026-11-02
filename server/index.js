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

  try {
    const params = new URLSearchParams();
    params.append('grant_type', 'client_credentials');
    params.append('client_id', process.env.TOSS_CLIENT_ID);
    params.append('client_secret', process.env.TOSS_CLIENT_SECRET);

    console.log('토큰 발급 요청 중...');
    const response = await axios.post(`${process.env.TOSS_API_BASE_URL}/oauth2/token`, params, {
      headers: {
        'Content-Type': 'application/x-www-form-urlencoded',
      },
    });

    cachedAccessToken = response.data.access_token;
    tokenExpiresAt = now + (response.data.expires_in - 600) * 1000;
    console.log('토큰 발급 성공!');
    return cachedAccessToken;
  } catch (error) {
    console.error(' [토큰 발급 에러 발생]:', error.response?.data || error.message);
    throw error;
  }
}

app.get('/api/account/balance', async (req, res) => {
  try {
    const accessToken = await getTossAccessToken();
    
    console.log('계좌 잔고 조회 요청 중...');
    const tossResponse = await axios.get(`${process.env.TOSS_API_BASE_URL}/v1/trading/accounts/balance`, {
      headers: { Authorization: `Bearer ${accessToken}` },
    });
    
    res.json(tossResponse.data);
  } catch (error) {
    console.error(' [계좌 잔고 조회 에러 발생]:', error.response?.data || error.message);
    res.status(500).json({ error: error.response?.data || error.message });
  }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Proxy server running on port ${PORT}`));