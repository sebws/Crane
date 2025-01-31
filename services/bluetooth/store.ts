import { proxy, ref, subscribe } from "valtio";
import { BleManager, State, type Device } from "react-native-ble-plx";
import type { Scale } from "@/devices/types";
import { DEVICE_TYPES } from "@/devices";
import { ConnectionState } from "@/types";
import { measurementActions } from "./measurementStore";

interface BluetoothState {
	state: ConnectionState;
	scanning: boolean;
	devices: Scale[];
	connectedDevice: Scale | null;
	error: Error | null;
}

const manager = new BleManager();

function wrapDevice(device: Device): Scale | null {
	let wrapped: Scale | null = null;
	DEVICE_TYPES.find((type) => {
		wrapped = type.wrap(device);
		return wrapped !== null;
	});
	return wrapped;
}

export const store = proxy<BluetoothState>({
	state: ConnectionState.Unknown,
	scanning: false,
	devices: [],
	connectedDevice: null,
	error: null,
});

export const actions = {
	async startScan() {
		if (store.scanning) return;
		for (const device of await manager.connectedDevices(
			DEVICE_TYPES.map((d) => d.SERVICE_UUID),
		)) {
			const wrapped = wrapDevice(device);
			if (wrapped) {
				store.connectedDevice = wrapped;
				store.state = ConnectionState.Connected;
				break;
			}
		}

		store.scanning = true;
		store.devices = [];

		manager.startDeviceScan(
			null,
			{ allowDuplicates: false },
			(error, device) => {
				if (error) {
					store.scanning = false;
					store.error = error;
					return;
				}

				if (device) {
					const wrapped = wrapDevice(device);
					if (wrapped && !store.devices.find((d) => d.id === device.id)) {
						store.devices.push(wrapped);
					}
				}
			},
		);

		setTimeout(() => actions.stopScan(), 10000);
	},

	stopScan() {
		manager.stopDeviceScan();
		store.scanning = false;
	},

	async connectToDevice(device: Scale) {
		try {
			store.state = ConnectionState.Connecting;

			await device.device.connect();
			await device.device.discoverAllServicesAndCharacteristics();

			store.connectedDevice = ref(device);
			store.state = ConnectionState.Connected;

			device.device.onDisconnected(() => {
				store.connectedDevice = null;
				store.state = ConnectionState.Disconnected;
				measurementActions.clear();
			});
		} catch (error) {
			store.error = error as Error;
			store.state = ConnectionState.Disconnected;
			throw error;
		}
	},

	async disconnectDevice() {
		const device = store.connectedDevice;
		if (!device) return;

		try {
			store.state = ConnectionState.Disconnecting;
			await actions.stopMeasurement();
			await device.device.cancelConnection();
			store.connectedDevice = null;
			store.state = ConnectionState.Disconnected;
			measurementActions.clear();
		} catch (error) {
			store.error = error as Error;
			throw error;
		}
	},

	async startMeasurement() {
		const device = store.connectedDevice;
		if (!device) return;

		try {
			await device.startMeasurement();
			await device.startNotifications((force) => {
				measurementActions.addMeasurement(force);
			});
		} catch (error) {
			store.error = error as Error;
			throw error;
		}
	},

	async stopMeasurement() {
		const device = store.connectedDevice;
		if (!device) return;

		try {
			await device.stopMeasurement();
			device.stopNotifications();
			measurementActions.clear();
		} catch (error) {
			store.error = error as Error;
			throw error;
		}
	},

	clearMeasurements() {
		measurementActions.clear();
	},
};

// Initialize bluetooth state monitoring
manager.onStateChange((state) => {
	switch (state) {
		case State.PoweredOff:
		case State.Unauthorized:
		case State.Unknown:
		case State.Resetting:
		case State.Unsupported:
			store.state = ConnectionState.Off;
			break;
		case State.PoweredOn:
			store.state = ConnectionState.On;
			// Check for connected device
			manager.connectedDevices([]).then((devices) => {
				for (const device of devices) {
					const wrapped = wrapDevice(device);
					if (wrapped) {
						store.connectedDevice = wrapped;
						store.state = ConnectionState.Connected;
						break;
					}
				}
			});
			break;
	}
}, true);
