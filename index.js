'use strict';
require('dotenv').config();
const { createConstellation, OUTPUTS } = require('./core/constellation');
const { createApp } = require('./api/server');

if (require.main === module) {
  const app = createApp();
  const port = Number.parseInt(process.env.PORT || '3000', 10);
  if (!Number.isInteger(port) || port < 1 || port > 65535) {
    console.error('PORT must be an integer from 1 to 65535');
    process.exit(1);
  }
  app.listen(port, '0.0.0.0', () => console.log('C25 runtime listening on port ' + port));
}
module.exports = { createConstellation, OUTPUTS, createApp };
