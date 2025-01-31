import type { FontAwesome6 } from "@expo/vector-icons";
import type {
	Device,
} from "react-native-ble-plx";

export abstract class Scale {
	public device: Device;
	protected constructor(device: Device) {
		this.device = device;
	}

	abstract get type(): "progressor" | "whc06";
	abstract startMeasurement(): Promise<void>;
	abstract stopMeasurement(): Promise<void>;
	abstract startNotifications(callback: (force: number) => void): Promise<void>;
	abstract stopNotifications(): void;

	abstract readonly iconName: React.ComponentProps<typeof FontAwesome6>["name"];

	static wrap(device: Device): Scale | null {
		return null;
	}

	get id() {
		return this.device.id;
	}
	get name() {
		return this.device.name ?? "Unknown Device";
	}
}
