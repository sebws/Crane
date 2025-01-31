import {
	BleManager,
	type Device,
	State,
	type UUID,
} from "react-native-ble-plx";
import { ConnectionState } from "@/types";
import type { Scale } from "@/devices/types";
import { DEVICE_TYPES } from "@/devices";
import { EventEmitter } from "events";

class BluetoothManager extends EventEmitter {
	private manager: BleManager;
	private connectedDevice: Scale | null = null;
	private discoveredDevices: Map<string, Scale> = new Map();
	private isScanning = false;

	constructor() {
		super();
		this.manager = new BleManager();
	}

	async checkState(): Promise<boolean> {
		const state = await this.manager.state();
		const isEnabled = state === State.PoweredOn;
		this.emit("stateChange", isEnabled);
		return isEnabled;
	}

	async startScan(uuids?: UUID[]): Promise<void> {
		if (this.isScanning) return;

		this.isScanning = true;
		this.discoveredDevices.clear();
		this.emit("scanningChange", true);
		this.emit("devicesChange", []);

		this.manager.startDeviceScan(
			uuids ?? null,
			{ allowDuplicates: true },
			(error, device) => {
				if (error) {
					console.error("Scan error:", error);
					this.stopScan();
					return;
				}

				if (device) {
					this.addDeviceIfIsScale(device);
				}
			},
		);
	}

	private addDeviceIfIsScale(device: Device) {
		let wrapped: Scale | null = null;
		DEVICE_TYPES.find((type) => {
			wrapped = type.wrap(device);
			return wrapped !== null;
		});

		if (wrapped && !this.discoveredDevices.has(device.id)) {
			this.discoveredDevices.set(device.id, wrapped);
			this.emit("devicesChange", Array.from(this.discoveredDevices.values()));
		}
	}

	stopScan(): void {
		this.manager.stopDeviceScan();
		this.isScanning = false;
		this.emit("scanningChange", false);
	}

	async connectToDevice(device: Scale): Promise<void> {
		this.emit("connectionStateChange", ConnectionState.Connecting);
		try {
			this.connectedDevice = device;
			this.emit("connectionStateChange", ConnectionState.Connected);
			this.emit("connectedDeviceChange", device);
		} catch (error) {
			console.error("Connection error:", error);
			this.emit("connectionStateChange", ConnectionState.Disconnected);
			throw error;
		}
	}

	async disconnect(): Promise<void> {
		if (!this.connectedDevice) return;

		this.emit("connectionStateChange", ConnectionState.Disconnecting);
		try {
			this.manager.cancelDeviceConnection(this.connectedDevice.id);
			this.connectedDevice = null;
			this.emit("connectionStateChange", ConnectionState.Disconnected);
			this.emit("connectedDeviceChange", null);
		} catch (error) {
			console.error("Disconnect error:", error);
			throw error;
		}
	}

	destroy(): void {
		this.stopScan();
		this.manager.destroy();
	}
}

export const manager = new BluetoothManager();
