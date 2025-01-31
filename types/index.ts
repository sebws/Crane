export type DeviceType = "progressor" | "whc06";

export interface DeviceData {
	value: number;
	timestamp: number;
}

export enum ConnectionState {
	Disconnected = "Disconnected",
	Connecting = "Connecting",
	Connected = "Connected",
	Disconnecting = "Disconnecting",
	DiscoveringServices = "Discovering services",
	Off = "Off",
	On = "On",
	Disabled = "Disabled",
	Unknown = "Unknown",
}
