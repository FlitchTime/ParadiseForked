import { createSearch } from 'common/string';
import { declension_ru } from 'common/string';
import { useBackend } from '../backend';
import { useState } from 'react';
import {
  Box,
  Dimmer,
  Dropdown,
  ImageButton,
  Button,
  Input,
  Section,
  Tabs,
  ProgressBar,
  Stack,
  LabeledList,
} from '../components';
import { Window } from '../layouts';

type Data = {
  user_tier: number;
  gear_slots: number;
  max_gear_slots: number;
  selected_gears: string[];
  gears: Record<string, Record<string, Gear>>;
};

type Gear = {
  name: string;
  index_name: string;
  desc: string;
  icon: string;
  icon_state: string;
  cost: number;
  gear_tier: number;
  allowed_roles: string[];
  tweaks: Record<string, Tweak[]>;
};

type Tweak = {
  name: string;
  icon: string;
  tooltip: string;
};

const sortTypes = {
  'По умолчанию': (a, b) => a.gear.gear_tier - b.gear.gear_tier,
  'По алфавиту': (a, b) =>
    a.gear.name.toLowerCase().localeCompare(b.gear.name.toLowerCase()),
  'По стоимости': (a, b) => a.gear.cost - b.gear.cost,
};

export const Loadout = (props: unknown) => {
  const { act, data } = useBackend<Data>();
  const [search, setSearch] = useState(false);
  const [searchText, setSearchText] = useState('');
  const [category, setCategory] = useState(Object.keys(data.gears)[0]);
  const [tweakedGear, setTweakedGear] = useState('');

  return (
    <Window width={975} height={650}>
      {tweakedGear && (
        <GearTweak tweakedGear={tweakedGear} setTweakedGear={setTweakedGear} />
      )}
      <Window.Content scrollable>
        <Stack fill vertical>
          <Stack.Item>
            <LoadoutCategories category={category} setCategory={setCategory} />
          </Stack.Item>
          <Stack.Item grow>
            <Stack fill>
              <Stack.Item basis="25%">
                <LoadoutEquipped setTweakedGear={setTweakedGear} />
              </Stack.Item>
              <Stack.Item basis="75%">
                <LoadoutGears
                  category={category}
                  search={search}
                  setSearch={setSearch}
                  searchText={searchText}
                  setSearchText={setSearchText}
                />
              </Stack.Item>
            </Stack>
          </Stack.Item>
        </Stack>
      </Window.Content>
    </Window>
  );
};

const LoadoutCategories = (props) => {
  const { data } = useBackend<Data>();
  const { category, setCategory } = props;
  return (
    <Tabs fluid textAlign="center" style={{ flexWrap: 'wrap-reverse' }}>
      {Object.keys(data.gears).map((cat) => (
        <Tabs.Tab
          key={cat}
          selected={cat === category}
          style={{
            whiteSpace: 'nowrap',
          }}
          onClick={() => setCategory(cat)}
        >
          {cat}
        </Tabs.Tab>
      ))}
    </Tabs>
  );
};

const LoadoutGears = (props) => {
  const { act, data } = useBackend<Data>();
  const { user_tier, gear_slots, max_gear_slots } = data;
  const { category, search, setSearch, searchText, setSearchText } = props;

  const [sortType, setSortType] = useState('По умолчанию');
  const [sortReverse, setsortReverse] = useState(false);
  const testSearch = createSearch<Gear>(searchText, (gear) => gear.name);

  let contents;
  if (searchText.length > 2) {
    contents = Object.entries(data.gears)
      .reduce((a, [key, gears]) => {
        return a.concat(
          Object.entries(gears).map(([key, gear]) => ({ key, gear }))
        );
      }, [])
      .filter(({ gear }) => {
        return testSearch(gear);
      });
  } else {
    contents = Object.entries(data.gears[category]).map(([key, gear]) => ({
      key,
      gear,
    }));
  }

  contents.sort(sortTypes[sortType]);
  if (sortReverse) {
    contents = contents.reverse();
  }

  return (
    <Section
      fill
      scrollable
      title={category}
      buttons={
        <Stack>
          <Stack.Item>
            <Dropdown
              height={1.66}
              selected={sortType}
              options={Object.keys(sortTypes)}
              onSelected={(value) => setSortType(value)}
            />
          </Stack.Item>
          <Stack.Item>
            <Button
              icon={
                sortReverse ? 'arrow-down-wide-short' : 'arrow-down-short-wide'
              }
              tooltip={sortReverse ? 'По возрастанию' : 'По убыванию'}
              tooltipPosition="bottom-end"
              onClick={() => setsortReverse(!sortReverse)}
            />
          </Stack.Item>
          {search && (
            <Stack.Item>
              <Input
                width={20}
                placeholder="Поиск..."
                value={searchText}
                expensive
                onChange={setSearchText}
              />
            </Stack.Item>
          )}
          <Stack.Item>
            <Button
              icon="magnifying-glass"
              selected={search}
              tooltip="Включить поисковую строку"
              tooltipPosition="bottom-end"
              onClick={() => {
                setSearch(!search);
                setSearchText('');
              }}
            />
          </Stack.Item>
        </Stack>
      }
    >
      {contents.map(({ key, gear }) => {
        const maxTextLength = 12;
        const selected = Object.keys(data.selected_gears).includes(key);
        const costText =
          gear.cost === 1
            ? `${gear.cost} Очк` + declension_ru(gear.cost, 'о', 'а', 'ов')
            : `${gear.cost} Очк` + declension_ru(gear.cost, 'о', 'а', 'ов');
        const tooltipText = (
          <Box>
            {gear.name.length > maxTextLength && <Box>{gear.name}</Box>}
            {gear.gear_tier > user_tier && (
              <Box mt={gear.name.length > maxTextLength && 1.5} textColor="red">
                Недоступно на вашем текущем уровне пожертвований!
              </Box>
            )}
          </Box>
        );

        const tooltipsInfo = (
          <>
            {gear.allowed_roles && (
              <Button
                width="22px"
                color="transparent"
                icon="user"
                tooltip={
                  <Section m={-1} title="Разрешённые должности">
                    {gear.allowed_roles.map((role) => (
                      <Box key={role}>{role}</Box>
                    ))}
                  </Section>
                }
                tooltipPosition="left"
              />
            )}
            {Object.entries(gear.tweaks).map(
              ([key, tweaks]: [string, Tweak[]]) =>
                tweaks.map((tweak) => (
                  <Button
                    key={key}
                    width="22px"
                    color="transparent"
                    icon={tweak.icon}
                    tooltip={tweak.tooltip}
                    tooltipPosition="top"
                  />
                ))
            )}
            <Button
              width="22px"
              color="transparent"
              icon="info"
              tooltip={gear.desc}
              tooltipPosition="top"
            />
          </>
        );

        const textInfo = (
          <Box className="Loadout-InfoBox">
            <Box
              style={{ flexGrow: '1' }}
              fontSize={0.75}
              color="gold"
              opacity={0.75}
            >
              {gear.gear_tier > 0 && `Уровень ${gear.gear_tier}`}
            </Box>
            <Box fontSize={0.75} opacity={0.66}>
              {costText}
            </Box>
          </Box>
        );

        return (
          <ImageButton
            key={key}
            m={0.5}
            imageSize={84}
            dmIcon={gear.icon}
            dmIconState={gear.icon_state}
            tooltip={
              (gear.name.length > maxTextLength || gear.gear_tier > 0) &&
              tooltipText
            }
            tooltipPosition={'bottom'}
            selected={selected}
            disabled={
              gear.gear_tier > user_tier ||
              (gear_slots + gear.cost > max_gear_slots && !selected)
            }
            buttons={tooltipsInfo}
            buttonsAlt={textInfo}
            onClick={() => act('toggle_gear', { gear: gear.index_name })}
          >
            {gear.name}
          </ImageButton>
        );
      })}
    </Section>
  );
};

const LoadoutEquipped = (props) => {
  const { act, data } = useBackend<Data>();
  const { setTweakedGear } = props;
  const selectedGears = Object.entries(data.gears).reduce(
    (a, [categoryKey, categoryItems]) => {
      const selectedInCategory = Object.entries(categoryItems)
        .filter(([gearKey]) =>
          Object.keys(data.selected_gears).includes(gearKey)
        )
        .map(([gearKey, gear]) => ({ key: gearKey, ...gear }));

      return a.concat(selectedInCategory);
    },
    []
  );
  return (
    <Stack fill vertical>
      <Stack.Item grow>
        <Section
          fill
          scrollable
          title={'Выбранное снаряжение'}
          buttons={
            <Button.Confirm
              icon="trash"
              tooltip={'Очистить список'}
              tooltipPosition={'bottom-end'}
              onClick={() => act('clear_loadout')}
            />
          }
        >
          {selectedGears.map((gear) => {
            let gear_data = data.selected_gears[gear.key];
            return (
              <ImageButton
                key={gear.key}
                fluid
                imageSize={48}
                base64={gear_data['icon']}
                dmIcon={
                  gear_data['icon_file'] ? gear_data['icon_file'] : gear.icon
                }
                dmIconState={
                  gear_data['icon_state']
                    ? gear_data['icon_state']
                    : gear.icon_state
                }
                buttons={
                  <>
                    {Object.entries(gear.tweaks).length > 0 && (
                      <Button
                        color="translucent"
                        icon="gears"
                        iconColor="gray"
                        width="33px"
                        onClick={() => setTweakedGear(gear)}
                      />
                    )}
                    <Button
                      color="translucent"
                      icon="times"
                      iconColor="red"
                      width="32px"
                      onClick={() =>
                        act('toggle_gear', { gear: gear.index_name })
                      }
                    />
                  </>
                }
              >
                {gear_data['name'] ? gear_data['name'] : gear.name}
              </ImageButton>
            );
          })}
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <ProgressBar
            value={data.gear_slots}
            maxValue={data.max_gear_slots}
            ranges={{
              bad: [data.max_gear_slots, Infinity],
              average: [data.max_gear_slots * 0.66, data.max_gear_slots],
              good: [0, data.max_gear_slots * 0.66],
            }}
          >
            <Box textAlign="center">
              Использовано очков {data.gear_slots}/{data.max_gear_slots}
            </Box>
          </ProgressBar>
        </Section>
      </Stack.Item>
    </Stack>
  );
};

const GearTweak = (props) => {
  const { act, data } = useBackend<Data>();
  const { tweakedGear, setTweakedGear } = props;

  return (
    <Dimmer>
      <Box className={'Loadout-Modal__background'}>
        <Section
          fill
          scrollable
          width={20}
          height={20}
          title={tweakedGear.name}
          buttons={
            <Button
              color="red"
              icon="times"
              tooltip="Закрыть"
              tooltipPosition="top"
              onClick={() => setTweakedGear('')}
            />
          }
        >
          <LabeledList>
            {Object.entries(tweakedGear.tweaks).map(
              ([key, tweaks]: [string, Tweak[]]) =>
                tweaks.map((tweak) => {
                  const tweakInfo = data.selected_gears[tweakedGear.key][key];
                  return (
                    <LabeledList.Item
                      key={key}
                      label={tweak.name}
                      color={tweakInfo ? '' : 'gray'}
                      buttons={
                        <Button
                          color="transparent"
                          icon={'pen'}
                          onClick={() =>
                            act('set_tweak', {
                              gear: tweakedGear.index_name,
                              tweak: key,
                            })
                          }
                        />
                      }
                    >
                      {tweakInfo ? tweakInfo : 'По умолчанию'}
                      <Box
                        inline
                        ml={1}
                        width={1}
                        height={1}
                        verticalAlign={'middle'}
                        style={{ backgroundColor: `${tweakInfo}` }}
                      />
                    </LabeledList.Item>
                  );
                })
            )}
          </LabeledList>
        </Section>
      </Box>
    </Dimmer>
  );
};
