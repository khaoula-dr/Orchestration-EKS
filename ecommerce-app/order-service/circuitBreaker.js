const axios = require('axios');
const CircuitBreaker = require('opossum');

const USER_SERVICE_URL = process.env.USER_SERVICE_URL || 'http://user-service:3000';
const PRODUCT_SERVICE_URL = process.env.PRODUCT_SERVICE_URL || 'http://product-service:3000';
const NOTIFICATION_SERVICE_URL = process.env.NOTIFICATION_SERVICE_URL || 'http://notification-service:3000';

// Un axios avec un timeout court : si user-service/product-service ne répond
// pas dans ce délai, on considère l'appel en échec plutôt que d'attendre indéfiniment.
const httpClient = axios.create({ timeout: 3000 });

// Options communes du circuit breaker :
// - timeout : durée max d'un appel avant de le considérer en échec (doublon volontaire
//   avec le timeout axios, opossum a besoin du sien pour compter les échecs)
// - errorThresholdPercentage : au-delà de 50% d'échecs sur la fenêtre, le circuit "s'ouvre"
// - resetTimeout : après combien de temps on retente un appel pour voir si le service est revenu
const breakerOptions = {
  timeout: 3000,
  errorThresholdPercentage: 50,
  resetTimeout: 10000,
};

// --- Appel vers user-service ---
async function callUserService(userId) {
  const response = await httpClient.get(`${USER_SERVICE_URL}/users/${userId}`);
  return response.data;
}
const userServiceBreaker = new CircuitBreaker(callUserService, breakerOptions);
userServiceBreaker.fallback(() => null); // si le circuit est ouvert, on renvoie null plutôt que de bloquer

// --- Appel vers product-service ---
async function callProductService(productId) {
  const response = await httpClient.get(`${PRODUCT_SERVICE_URL}/products/${productId}`);
  return response.data;
}
const productServiceBreaker = new CircuitBreaker(callProductService, breakerOptions);
productServiceBreaker.fallback(() => null);

// --- Appel vers notification-service (best-effort, ne doit jamais bloquer la réponse) ---
async function callNotificationService(payload) {
  await httpClient.post(`${NOTIFICATION_SERVICE_URL}/notifications`, payload);
}
const notificationServiceBreaker = new CircuitBreaker(callNotificationService, breakerOptions);
notificationServiceBreaker.fallback(() => {
  console.error('[order-service] notification-service indisponible (circuit ouvert), notification ignorée');
});

// Logs utiles pour voir l'état des circuits en conditions réelles (utile pour la démo/rapport)
[userServiceBreaker, productServiceBreaker, notificationServiceBreaker].forEach((breaker, i) => {
  const names = ['user-service', 'product-service', 'notification-service'];
  breaker.on('open', () => console.warn(`[circuit-breaker] ${names[i]} : circuit OUVERT (trop d'échecs)`));
  breaker.on('halfOpen', () => console.warn(`[circuit-breaker] ${names[i]} : circuit à moitié ouvert, test en cours`));
  breaker.on('close', () => console.log(`[circuit-breaker] ${names[i]} : circuit refermé, service de nouveau OK`));
});

module.exports = {
  getUser: (userId) => userServiceBreaker.fire(userId),
  getProduct: (productId) => productServiceBreaker.fire(productId),
  notifyUser: (payload) => notificationServiceBreaker.fire(payload),
};
