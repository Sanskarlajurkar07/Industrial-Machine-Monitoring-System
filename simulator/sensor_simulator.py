import random
import time
import json
from datetime import datetime
from mqtt_publisher import MqttPublisher
from config import (
    MACHINES,
    NORMAL_RANGES,
    ANOMALY_RANGES,
    PUBLISH_INTERVAL,
    ANOMALY_CHANCE
)


def generate_reading(machine: dict) -> dict:
    is_anomaly = random.random() < ANOMALY_CHANCE
    ranges     = ANOMALY_RANGES if is_anomaly else NORMAL_RANGES

    temperature = round(random.uniform(*ranges["temperature"]), 2)
    vibration   = round(random.uniform(*ranges["vibration"]), 2)
    rpm         = random.randint(*ranges["rpm"])
    pressure    = round(random.uniform(*ranges["pressure"]), 2)

    reading = {
        "machineId":   machine["id"],
        "machineName": machine["name"],
        "temperature": temperature,
        "vibration":   vibration,
        "rpm":         rpm,
        "pressure":    pressure,
        "timestamp":   datetime.now().isoformat(),
    }

    if is_anomaly:
        print(f"⚠️  ANOMALY → {machine['id']} | "
              f"temp={temperature} | vib={vibration} | "
              f"rpm={rpm} | pressure={pressure}")

    return reading


def run():
    publisher = MqttPublisher()
    publisher.connect()

    time.sleep(1)

    print("=" * 55)
    print("  Industrial Machine Simulator")
    print(f"  Machines : {len(MACHINES)}")
    print(f"  Interval : {PUBLISH_INTERVAL}s per cycle")
    print(f"  Anomaly  : {int(ANOMALY_CHANCE * 100)}% chance per reading")
    print("=" * 55)

    reading_count = 0

    while True:
        for machine in MACHINES:
            reading = generate_reading(machine)
            payload = json.dumps(reading)
            publisher.publish(payload)
            reading_count += 1

        if reading_count % 100 == 0:
            print(f"📡 {reading_count} readings published...")

        time.sleep(PUBLISH_INTERVAL)


if __name__ == "__main__":
    run()