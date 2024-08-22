import { requireNativeViewManager } from 'expo-modules-core';
import * as React from 'react';

import { ScannyViewProps } from './Scanny.types';

const NativeView: React.ComponentType<ScannyViewProps> =
  requireNativeViewManager('Scanny');

export default function ScannyView(props: ScannyViewProps) {
  return <NativeView {...props} />;
}
