import type { Device } from "react-native-ble-plx";
import { Scale } from "./types";
import { Buffer } from "buffer";

export class WHC06 extends Scale {
	static readonly SERVICE_UUID = "FFE0";
	static readonly CHARACTERISTIC_UUID = "FFE1";
	readonly iconName = "weight-scale" as const;
	private callback?: (force: number) => void;

	static wrap(device: Device): WHC06 | null {
		return device.name?.toLowerCase().includes("whc")
			? new WHC06(device)
			: null;
	}

	get type() {
		return "whc06" as const;
	}

	async startMeasurement(): Promise<void> {
		// WHC06 doesn't need to start measurement - it's always advertising
	}

	async stopMeasurement(): Promise<void> {
		this.stopNotifications();
	}

	async startNotifications(onData: (force: number) => void): Promise<void> {
		this.callback = onData;
		// Start monitoring advertisement data
		this.device.((error, scanResult) => {
			if (error || !scanResult?.manufacturerData) return;

			const data = Buffer.from(scanResult.manufacturerData, "base64");
			if (data.length < 14) return; // Need at least 14 bytes for weight data

			// Weight is at offset 12, 2 bytes, big endian
			const weight = data.readInt16BE(12) / 100;
			this.callback?.(weight);
		});
	}

	stopNotifications(): void {
		this.callback = undefined;
	}

	async disconnect(): Promise<void> {
		this.stopNotifications();
	}
}
