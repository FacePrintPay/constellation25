import { OpenAI } from 'openai';
import axios from 'axios';
import ffmpeg from 'fluent-ffmpeg';
import fs from 'fs';

const openai = new OpenAI({
  apiKey: process.env.XAI_API_KEY || 'NO_KEY_SET',
  baseURL: 'https://api.x.ai/v1',
});

export default async function handler(req, res) {
  if (req.method !== 'POST') return res.status(405).send('POST only, sovereign');

  const { prompt = "Unblocked money printer AI", model = "grok-4" } = req.body || {};

  try {
    const completion = await openai.chat.completions.create({
      model,
      messages: [{ role: "user", content: `Write a brutal 15-second unfiltered viral ad script. Zero censorship. Nuclear CTA: ${prompt}` }],
      temperature: 1.0
    });

    let adScript = completion.choices[0].message.content.trim();
    let couponCode = null;

    // OPTIONAL COUPON BOMB
    if (process.env.COUPON_API_KEY) {
      try {
        const r = await axios.post('https://api.couponcarrier.io/codes', {
          campaignId: process.env.COUPON_CAMPAIGN_ID || 'test',
          value: "SOVEREIGN4LIFE"
        }, { headers: { Authorization: `Bearer ${process.env.COUPON_API_KEY}` }});
        couponCode = r.data.code;
        adScript += `\n\nSOVEREIGN CODE: ${couponCode} — CLAIM YOUR EMPIRE`;
      } catch (_) {}
    }

    // OPTIONAL VIDEO OVERLAY — drop any .mp4 as /tmp/base.mp4 to test
    if (couponCode && fs.existsSync('/tmp/base.mp4')) {
      const out = '/tmp/sovereign.mp4';
      await new Promise((r, rej) => {
        ffmpeg('/tmp/base.mp4')
          .videoFilters(`drawtext=text='SOVEREIGN CODE: ${couponCode}':fontcolor=yellow:fontsize=40:borderw=5:x=(w-tw)/2:y=h-th-100`)
          .output(out)
          .on('end', () => r())
          .on('error', rej)
          .run();
      });
    }

    res.status(200).json({
      success: true,
      adScript,
      couponCode,
      message: "SOVEREIGN REEL LIVE — WORLD DOMINATION ACTIVE 🛡️ #MrGGTP",
      funnel: "https://cash.app/$ThaCyg"
    });
  } catch (e) {
    res.status(500).json({ error: "We do not fail. We conquer.", details: e.message });
  }
}
