import paho.mqtt.client as mqtt
from config import MQTT_BROKER_HOST, MQTT_BROKER_PORT
import logging

logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)


class MqttPublisher:

    def __init__(self):
        self.client = mqtt.Client(client_id="python-simulator")
        self.client.on_connect    = self._on_connect
        self.client.on_disconnect = self._on_disconnect

    def _on_connect(self, client, userdata, flags, rc):
        if rc == 0:
            logger.info("Connected to MQTT broker at %s:%s",
                        MQTT_BROKER_HOST, MQTT_BROKER_PORT)
        else:
            logger.error("MQTT connection failed. Code: %s", rc)

    def _on_disconnect(self, client, userdata, rc):
        logger.warning("Disconnected from MQTT broker")

    def connect(self):
        self.client.connect(MQTT_BROKER_HOST, MQTT_BROKER_PORT)
        self.client.loop_start()

    def publish(self, payload: str):
        result = self.client.publish(
            "machines/readings", payload, qos=1
        )
        return result.rc == 0

    def disconnect(self):
        self.client.loop_stop()
        self.client.disconnect()