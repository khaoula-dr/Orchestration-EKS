// tracing.js
// Auto-instrumentation OpenTelemetry : patch automatiquement express, axios,
// pg et mongoose au chargement, sans toucher au code métier de index.js.
// Le nom du service et l'endpoint Jaeger viennent des variables d'environnement
// OTEL_SERVICE_NAME / OTEL_EXPORTER_OTLP_ENDPOINT (injectées par Helm).

const { NodeSDK } = require('@opentelemetry/sdk-node');
const { getNodeAutoInstrumentations } = require('@opentelemetry/auto-instrumentations-node');
const { OTLPTraceExporter } = require('@opentelemetry/exporter-trace-otlp-http');

const sdk = new NodeSDK({
  traceExporter: new OTLPTraceExporter({
    url: `${process.env.OTEL_EXPORTER_OTLP_ENDPOINT || 'http://localhost:4318'}/v1/traces`,
  }),
  instrumentations: [getNodeAutoInstrumentations()],
});

sdk.start();

process.on('SIGTERM', () => {
  sdk.shutdown().finally(() => process.exit(0));
});