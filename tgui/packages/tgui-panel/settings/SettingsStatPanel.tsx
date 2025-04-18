import { toFixed } from 'common/math';
import { capitalize } from 'common/string';
import { useLocalState } from 'tgui/backend';
import { useDispatch, useSelector } from 'common/redux';
import {
  Button,
  LabeledList,
  NoticeBox,
  Section,
  Slider,
  Stack,
  Collapsible,
  Input,
} from 'tgui/components';

import { FONTS } from './constants';

import { updateSettings } from './actions';
import { selectSettings } from './selectors';

const TabsViews = ['default', 'classic', 'scrollable'];
const LinkedToChat = () => (
  <NoticeBox color="red">Unlink Stat Panel from chat!</NoticeBox>
);

export const SettingsStatPanel = (props, context) => {
  const { statLinked, statFontSize, statFontFamily, statTabsStyle } =
    useSelector(context, selectSettings);
  const dispatch = useDispatch(context);
  const [freeStatFont, setFreeStatFont] = useLocalState('freeStatFont', false);

  return (
    <Section fill>
      <Stack fill vertical>
        <Stack.Item>
          <LabeledList>
            <LabeledList.Item label="Tabs" verticalAlign="middle">
              {TabsViews.map((view) => (
                <Button
                  key={view}
                  color="transparent"
                  selected={statTabsStyle === view}
                  onClick={() =>
                    dispatch(updateSettings({ statTabsStyle: view }))
                  }
                >
                  {capitalize(view)}
                </Button>
              ))}
            </LabeledList.Item>
            <LabeledList.Item label="Font style">
              {statLinked ? (
                <LinkedToChat />
              ) : (
                <Stack.Item>
                  {!freeStatFont ? (
                    <Collapsible
                      title={statFontFamily}
                      width={'100%'}
                      buttons={
                        <Button
                          icon={freeStatFont ? 'lock-open' : 'lock'}
                          color={freeStatFont ? 'good' : 'bad'}
                          onClick={() => {
                            setFreeStatFont(!freeStatFont);
                          }}
                        >
                          Custom font
                        </Button>
                      }
                    >
                      {FONTS.map((FONT) => (
                        <Button
                          key={FONT}
                          fontFamily={FONT}
                          selected={statFontFamily === FONT}
                          color="transparent"
                          onClick={() =>
                            dispatch(
                              updateSettings({
                                statFontFamily: FONT,
                              })
                            )
                          }
                        >
                          {FONT}
                        </Button>
                      ))}
                    </Collapsible>
                  ) : (
                    <Stack>
                      <Input
                        width={'100%'}
                        value={statFontFamily}
                        onChange={(e, value) =>
                          dispatch(
                            updateSettings({
                              statFontFamily: value,
                            })
                          )
                        }
                      />
                      <Button
                        ml={0.5}
                        icon={freeStatFont ? 'lock-open' : 'lock'}
                        color={freeStatFont ? 'good' : 'bad'}
                        onClick={() => {
                          setFreeStatFont(!freeStatFont);
                        }}
                      >
                        Custom font
                      </Button>
                    </Stack>
                  )}
                </Stack.Item>
              )}
            </LabeledList.Item>
            <LabeledList.Item label="Font size">
              <Stack.Item grow>
                {statLinked ? (
                  <LinkedToChat />
                ) : (
                  <Slider
                    width="100%"
                    step={1}
                    stepPixelSize={20}
                    minValue={8}
                    maxValue={32}
                    value={statFontSize}
                    unit="px"
                    format={(value) => toFixed(value)}
                    onChange={(e, value) =>
                      dispatch(updateSettings({ statFontSize: value }))
                    }
                  />
                )}
              </Stack.Item>
            </LabeledList.Item>
          </LabeledList>
        </Stack.Item>
        <Stack.Divider mt={2.5} />
        <Stack.Item textAlign="center">
          <Button
            fluid
            icon={statLinked ? 'unlink' : 'link'}
            color={statLinked ? 'bad' : 'good'}
            onClick={() =>
              dispatch(updateSettings({ statLinked: !statLinked }))
            }
          >
            {statLinked ? 'Unlink from chat' : 'Link to chat'}
          </Button>
        </Stack.Item>
      </Stack>
    </Section>
  );
};
