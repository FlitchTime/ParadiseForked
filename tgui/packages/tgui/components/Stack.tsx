/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

import { classes } from 'common/react';
import { RefObject } from 'inferno';
import {
  computeFlexClassName,
  computeFlexItemClassName,
  computeFlexItemProps,
  computeFlexProps,
  FlexItemProps,
  FlexProps,
} from './Flex';

type StackProps = FlexProps & {
  /** Fills available space. */
  fill?: boolean;
  /** Reverses the stack. */
  reverse?: boolean;
  /** Flex column */
  vertical?: boolean;
  /** Adds zebra striping to the stack. */
  zebra?: boolean;
};

export const Stack = (props: StackProps) => {
  const { className, vertical, fill, reverse, zebra, ...rest } = props;

  const directionPrefix = vertical ? 'column' : 'row';
  const directionSuffix = reverse ? '-reverse' : '';

  return (
    <div
      className={classes([
        'Stack',
        fill && 'Stack--fill',
        vertical ? 'Stack--vertical' : 'Stack--horizontal',
        zebra && 'Stack--zebra',
        reverse && `Stack--reverse${vertical ? '--vertical' : ''}`,
        className,
        computeFlexClassName(props),
      ])}
      {...computeFlexProps({
        direction: `${directionPrefix}${directionSuffix}`,
        ...rest,
      })}
    />
  );
};

type StackItemProps = FlexProps & {
  innerRef?: RefObject<HTMLDivElement>;
};

const StackItem = (props: StackItemProps) => {
  const { className, innerRef, ...rest } = props;
  return (
    <div
      className={classes([
        'Stack__item',
        className,
        computeFlexItemClassName(rest),
      ])}
      ref={innerRef}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Item = StackItem;

type StackDividerProps = FlexItemProps & {
  hidden?: boolean;
};

const StackDivider = (props: StackDividerProps) => {
  const { className, hidden, ...rest } = props;
  return (
    <div
      className={classes([
        'Stack__item',
        'Stack__divider',
        hidden && 'Stack__divider--hidden',
        className,
        computeFlexItemClassName(rest),
      ])}
      {...computeFlexItemProps(rest)}
    />
  );
};

Stack.Divider = StackDivider;
