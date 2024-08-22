import * as React from 'react';

import { ScannyViewProps } from './Scanny.types';

export default function ScannyView(props: ScannyViewProps) {
  return (
    <div>
      <span>{props.name}</span>
    </div>
  );
}
