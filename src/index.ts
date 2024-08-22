import { NativeModulesProxy, EventEmitter, Subscription } from 'expo-modules-core';

// Import the native module. On web, it will be resolved to Scanny.web.ts
// and on native platforms to Scanny.ts
import ScannyModule from './ScannyModule';
import ScannyView from './ScannyView';
import { ChangeEventPayload, ScannyViewProps } from './Scanny.types';

// Get the native constant value.
export const PI = ScannyModule.PI;

export function hello(): string {
  return ScannyModule.hello();
}

export async function setValueAsync(value: string) {
  return await ScannyModule.setValueAsync(value);
}

const emitter = new EventEmitter(ScannyModule ?? NativeModulesProxy.Scanny);

export function addChangeListener(listener: (event: ChangeEventPayload) => void): Subscription {
  return emitter.addListener<ChangeEventPayload>('onChange', listener);
}

export { ScannyView, ScannyViewProps, ChangeEventPayload };
