import { useBackend, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Table,
  Section,
  Dropdown,
  Input,
  BlockQuote,
  Box,
  Icon,
  Stack,
} from '../components';
import { Window } from '../layouts';

const donatorTiers = {
  0: 'Бесплатные',
  1: 'Tier I',
  2: 'Tier II',
  3: 'Tier III',
  4: 'Tier IV',
};

const gendersIcons = {
  'Мужской': {
    icon: 'mars',
    color: 'blue',
  },
  'Женский': {
    icon: 'venus',
    color: 'purple',
  },
  'Любой': {
    icon: 'venus-mars',
    color: 'white',
  },
};

const getCheckboxGroup = (
  itemsList,
  selectedList,
  setSelected,
  contentKey = null
) => {
  return itemsList.map((item) => {
    const title = item[contentKey] ?? item;
    return (
      <Button.Checkbox
        key={title}
        checked={selectedList.includes(item)}
        content={title}
        onClick={() => {
          if (selectedList.includes(item)) {
            setSelected(
              selectedList.filter((i) => (i[contentKey] ?? i) !== item)
            );
          } else {
            setSelected([item, ...selectedList]);
          }
        }}
      />
    );
  });
};

export const TTSSeedsExplorer = (props) => {
  return (
    <Window width={700} height={800}>
      <Window.Content>
        <TTSSeedsExplorerContent />
      </Window.Content>
    </Window>
  );
};

export const TTSSeedsExplorerContent = (props) => {
  const { act, data } = useBackend();

  const { providers, seeds, selected_seed, phrases, donator_level } = data;

  const categories = seeds
    .map((seed) => seed.category)
    .filter((category, i, a) => a.indexOf(category) === i);
  const genders = seeds
    .map((seed) => seed.gender)
    .filter((gender, i, a) => a.indexOf(gender) === i);
  const donatorLevels = seeds
    .map((seed) => seed.donator_level)
    .filter((level, i, a) => a.indexOf(level) === i)
    .map((level) => donatorTiers[level]);

  const [selectedProviders, setSelectedProviders] = useLocalState(
    'selectedProviders',
    providers
  );
  const [selectedGenders, setSelectedGenders] = useLocalState(
    'selectedGenders',
    genders
  );
  const [selectedCategories, setSelectedCategories] = useLocalState(
    'selectedCategories',
    categories
  );
  const [selectedDonatorLevels, setSelectedDonatorLevels] = useLocalState(
    'selectedDonatorLevels',
    donatorLevels
  );
  const [selectedPhrase, setSelectedPhrase] = useLocalState(
    'selectedPhrase',
    phrases[0]
  );
  const [searchtext, setSearchtext] = useLocalState('searchtext', '');

  let providerCheckboxes = getCheckboxGroup(
    providers,
    selectedProviders,
    setSelectedProviders,
    'name'
  );
  let genderesCheckboxes = getCheckboxGroup(
    genders,
    selectedGenders,
    setSelectedGenders
  );
  let categoriesCheckboxes = getCheckboxGroup(
    categories,
    selectedCategories,
    setSelectedCategories
  );
  let donatorLevelsCheckboxes = getCheckboxGroup(
    donatorLevels,
    selectedDonatorLevels,
    setSelectedDonatorLevels
  );

  let phrasesSelect = (
    <Dropdown
      options={phrases}
      selected={selectedPhrase.replace(/(.{25})..+/, '$1...')}
      width="220px"
      onSelected={(value) => setSelectedPhrase(value)}
    />
  );

  let searchBar = (
    <Input
      placeholder="Название..."
      fluid
      onInput={(e, value) => setSearchtext(value)}
    />
  );

  const availableSeeds = seeds
    .sort((a, b) => {
      const aname = a.name.toLowerCase();
      const bname = b.name.toLowerCase();
      if (aname > bname) {
        return 1;
      }
      if (aname < bname) {
        return -1;
      }
      return 0;
    })
    .filter(
      (seed) =>
        selectedProviders.some((provider) => provider.name === seed.provider) &&
        selectedGenders.includes(seed.gender) &&
        selectedCategories.includes(seed.category) &&
        selectedDonatorLevels.includes(donatorTiers[seed.donator_level]) &&
        seed.name.toLowerCase().includes(searchtext.toLowerCase())
    );

  let seedsRow = availableSeeds.map((seed) => {
    return (
      <Table.Row
        key={seed.name}
        backgroundColor={selected_seed === seed.name ? 'green' : 'transparent'}
      >
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            color={selected_seed === seed.name ? 'green' : 'transparent'}
            content={selected_seed === seed.name ? 'Выбрано' : 'Выбрать'}
            tooltip={
              donator_level < seed.donator_level &&
              'Требуется более высокий уровень подписки'
            }
            tooltipPosition="right"
            textAlign="left"
            onClick={() => act('select', { seed: seed.name })}
          />
        </Table.Cell>
        <Table.Cell collapsing textAlign="center">
          <Button
            fluid
            icon="music"
            content=""
            tooltip="Прослушать пример"
            color="transparent"
            onClick={() =>
              act('listen', { seed: seed.name, phrase: selectedPhrase })
            }
          />
        </Table.Cell>
        <Table.Cell
          bold
          textColor={
            seed.donator_level > 0 && selected_seed !== seed.name
              ? 'orange'
              : 'white'
          }
        >
          {seed.name}
        </Table.Cell>
        <Table.Cell
          collapsing
          opacity={selected_seed === seed.name ? 0.5 : 0.25}
          textAlign="left"
        >
          {seed.category}
        </Table.Cell>
        <Table.Cell
          collapsing
          opacity={0.5}
          textColor={
            selected_seed === seed.name
              ? 'white'
              : gendersIcons[seed.gender].color
          }
          textAlign="left"
        >
          <Icon mx={1} size={1.2} name={gendersIcons[seed.gender].icon} />
        </Table.Cell>
        <Table.Cell
          collapsing
          opacity={0.5}
          textColor="white"
          textAlign="right"
        >
          {seed.donator_level > 0 && (
            <>
              {donatorTiers[seed.donator_level]}
              <Icon ml={1} mr={2} name="coins" />
            </>
          )}
        </Table.Cell>
      </Table.Row>
    );
  });

  return (
    <Stack vertical fill>
      <Stack.Item>
        <Section title="Фильтры" fill>
          <LabeledList>
            <LabeledList.Item label="Провайдеры">
              {providerCheckboxes}
            </LabeledList.Item>
            <LabeledList.Item label="Пол">
              {genderesCheckboxes}
            </LabeledList.Item>
            <LabeledList.Item label="Категории">
              {categoriesCheckboxes}
            </LabeledList.Item>
            <LabeledList.Item label="Уровень подписки">
              {donatorLevelsCheckboxes}
            </LabeledList.Item>
            <LabeledList.Item label="Фраза">{phrasesSelect}</LabeledList.Item>
            <LabeledList.Item label="Поиск">{searchBar}</LabeledList.Item>
          </LabeledList>
        </Section>
      </Stack.Item>
      <Stack.Item grow>
        <Section
          scrollable
          fill
          title={`Голоса (${availableSeeds.length}/${seeds.length})`}
        >
          <Table>{seedsRow}</Table>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Section>
          <BlockQuote>
            <Box>
              {`Для поддержания и развития сообщества в условиях растущих расходов часть голосов пришлось сделать доступными только за материальную поддержку сообщества.`}
            </Box>
            <Box italic>
              {`Подробнее об этом можно узнать в нашем Discord-сообществе.`}
            </Box>
          </BlockQuote>
        </Section>
      </Stack.Item>
    </Stack>
  );
};
