import type { Device, Subscription } from "react-native-ble-plx";
import { Scale } from "./types";
import { Buffer } from "buffer";

export class Progressor extends Scale {
	static readonly SERVICE_UUID = "7e4e1701-1ea6-40c9-9dcc-13d34ffead57";
	static readonly CONTROL_CHARACTERISTIC =
		"7e4e1703-1ea6-40c9-9dcc-13d34ffead57";
	static readonly DATA_CHARACTERISTIC = "7e4e1702-1ea6-40c9-9dcc-13d34ffead57";
	readonly iconName = "dumbbell" as const;

	private dataSubscription?: Subscription;

	static wrap(device: Device): Progressor | null {
		return device.serviceUUIDs?.includes(Progressor.SERVICE_UUID)
			? new Progressor(device)
			: null;
	}

	get type() {
		return "progressor" as const;
	}

	async startMeasurement(): Promise<void> {
		const command = Buffer.from([0x65, 0x00]);

		try {
			await this.device.writeCharacteristicWithoutResponseForService(
				Progressor.SERVICE_UUID,
				Progressor.CONTROL_CHARACTERISTIC,
				command.toString("base64"),
			);
		} catch (error) {
			console.error("Failed to start measurement:", error);
			throw error;
		}
	}

	async stopMeasurement(): Promise<void> {
		const command = Buffer.from([0x66, 0x00]);

		try {
			await this.device.writeCharacteristicWithoutResponseForService(
				Progressor.SERVICE_UUID,
				Progressor.CONTROL_CHARACTERISTIC,
				command.toString("base64"),
			);

			this.stopNotifications();
		} catch (error) {
			console.error("Failed to stop measurement:", error);
			throw error;
		}
	}

	async startNotifications(onData: (weight: number) => void): Promise<void> {
		try {
			this.dataSubscription = this.device.monitorCharacteristicForService(
				Progressor.SERVICE_UUID,
				Progressor.DATA_CHARACTERISTIC,
				(error, characteristic) => {
					if (error) {
						console.error("Notification error:", error);
						return;
					}

					if (characteristic?.value) {
						const weight = this.parseWeight(characteristic.value);
						onData(weight);
					}
				},
			);
		} catch (error) {
			console.error("Failed to start notifications:", error);
			throw error;
		}
	}

	stopNotifications(): void {
		if (this.dataSubscription) {
			this.dataSubscription.remove();
			this.dataSubscription = undefined;
		}
	}

	parseWeight(baseData: string): number {
		const data = Buffer.from(baseData, "base64");

		// Skip type (1 byte) and length (1 byte)
		if (data.length < 6) return 0;

		// Read float32 from byte offset 2
		const weight = data.readFloatLE(2);
		return weight / 1000;
	}

	async disconnect(): Promise<void> {
		this.stopNotifications();
		await this.device.cancelConnection();
	}
}
