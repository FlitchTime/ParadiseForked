import { createSearch, decodeHtmlEntities } from 'common/string';
import { useBackend, useLocalState } from '../backend';
import {
  Box,
  Button,
  Icon,
  Input,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Tabs,
  Table,
} from '../components';
import {
  ComplexModal,
  modalOpen,
  modalRegisterBodyOverride,
} from '../interfaces/common/ComplexModal';
import { Window } from '../layouts';
import { LoginInfo } from './common/LoginInfo';
import { LoginScreen } from './common/LoginScreen';
import { TemporaryNotice } from './common/TemporaryNotice';

const severities = {
  'Minor': 'lightgray',
  'Medium': 'good',
  'Harmful': 'average',
  'Dangerous!': 'bad',
  'BIOHAZARD THREAT!': 'darkred',
};

const medStatusStyles = {
  '*Deceased*': 'deceased',
  '*SSD*': 'ssd',
  'Physically Unfit': 'physically_unfit',
  'Disabled': 'disabled',
};

const doEdit = (field) => {
  modalOpen('edit', {
    field: field.edit,
    value: field.value,
  });
};

const virusModalBodyOverride = (modal) => {
  const virus = modal.args;
  return (
    <Section m="-1rem" pb="1.5rem" title={virus.name || 'Вирус'}>
      <Box mx="0.5rem">
        <LabeledList>
          <LabeledList.Item label="Количество стадий">
            {virus.max_stages}
          </LabeledList.Item>
          <LabeledList.Item label="Распространение">
            {virus.spread_text}
          </LabeledList.Item>
          <LabeledList.Item label="Возможные методы лечения">
            {virus.cure}
          </LabeledList.Item>
          <LabeledList.Item label="Заметки">{virus.desc}</LabeledList.Item>
          <LabeledList.Item label="Тяжесть" color={severities[virus.severity]}>
            {virus.severity}
          </LabeledList.Item>
        </LabeledList>
      </Box>
    </Section>
  );
};

export const MedicalRecords = (_properties) => {
  const { data } = useBackend();
  const { loginState, screen } = data;
  if (!loginState.logged_in) {
    return (
      <Window width={800} height={900}>
        <Window.Content>
          <LoginScreen />
        </Window.Content>
      </Window>
    );
  }

  let body;
  if (screen === 2) {
    // List Records
    body = <MedicalRecordsList />;
  } else if (screen === 3) {
    // Record Maintenance
    body = <MedicalRecordsMaintenance />;
  } else if (screen === 4) {
    // View Records
    body = <MedicalRecordsView />;
  } else if (screen === 5) {
    // Virus Database
    body = <MedicalRecordsViruses />;
  } else if (screen === 6) {
    // Medbot Tracking
    body = <MedicalRecordsMedbots />;
  }

  return (
    <Window width={800} height={900}>
      <ComplexModal />
      <Window.Content>
        <Stack fill vertical>
          <LoginInfo />
          <TemporaryNotice />
          <MedicalRecordsNavigation />
          {body}
        </Stack>
      </Window.Content>
    </Window>
  );
};

const MedicalRecordsList = (_properties) => {
  const { act, data } = useBackend();
  const { records } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [sortId, _setSortId] = useLocalState('sortId', 'name');
  const [sortOrder, _setSortOrder] = useLocalState('sortOrder', true);
  return (
    <>
      <Stack.Item>
        <Stack fill>
          <Stack.Item>
            <Button
              content="Медицинские записи"
              icon="wrench"
              ml="0.25rem"
              onClick={() => act('screen', { screen: 3 })}
            />
          </Stack.Item>
          <Stack.Item grow>
            <Input
              fluid
              placeholder="Введите Имя, ID, Физическое или Психологическое состояние"
              onInput={(e, value) => setSearchText(value)}
            />
          </Stack.Item>
        </Stack>
      </Stack.Item>
      <Stack.Item grow mt={0.5}>
        <Section fill scrollable>
          <Table className="MedicalRecords__list">
            <Table.Row bold>
              <SortButton id="name">Имя</SortButton>
              <SortButton id="id">ID</SortButton>
              <SortButton id="rank">Должность</SortButton>
              <SortButton id="p_stat">Физическое состояние</SortButton>
              <SortButton id="m_stat">Психологическое состояние</SortButton>
            </Table.Row>
            {records
              .filter(
                createSearch(searchText, (record) => {
                  return (
                    record.name +
                    '|' +
                    record.id +
                    '|' +
                    record.rank +
                    '|' +
                    record.p_stat +
                    '|' +
                    record.m_stat
                  );
                })
              )
              .sort((a, b) => {
                const i = sortOrder ? 1 : -1;
                return a[sortId].localeCompare(b[sortId]) * i;
              })
              .map((record) => (
                <Table.Row
                  key={record.id}
                  className={
                    'MedicalRecords__listRow--' + medStatusStyles[record.p_stat]
                  }
                  onClick={() =>
                    act('view_record', { view_record: record.ref })
                  }
                >
                  <Table.Cell>
                    <Icon name="user" /> {record.name}
                  </Table.Cell>
                  <Table.Cell>{record.id}</Table.Cell>
                  <Table.Cell>{record.rank}</Table.Cell>
                  <Table.Cell>{record.p_stat}</Table.Cell>
                  <Table.Cell>{record.m_stat}</Table.Cell>
                </Table.Row>
              ))}
          </Table>
        </Section>
      </Stack.Item>
    </>
  );
};

const MedicalRecordsMaintenance = (_properties) => {
  const { act } = useBackend();
  return (
    <Stack.Item grow textAlign="center">
      <Section fill>
        <Stack.Item grow>
          <Button
            fluid
            lineHeight={3}
            color="translucent"
            icon="download"
            content="Резервное копирование на дискету"
            disabled
          />
        </Stack.Item>
        <Stack.Item grow>
          <Button
            fluid
            lineHeight={3}
            color="translucent"
            icon="upload"
            content="Загрузить с дискеты"
            my="0.5rem"
            disabled
          />{' '}
        </Stack.Item>
        <Stack.Item grow>
          <Button.Confirm
            fluid
            lineHeight={3}
            icon="trash"
            color="translucent"
            content="Удалить базу данных медицинских записей"
            onClick={() => act('del_all')}
          />
        </Stack.Item>
      </Section>
    </Stack.Item>
  );
};

const MedicalRecordsView = (_properties) => {
  const { act, data } = useBackend();
  const { medical, printing } = data;
  return (
    <>
      <Stack.Item height="235px">
        <Section
          fill
          scrollable
          title="Основная информация"
          buttons={
            <Button
              icon={printing ? 'spinner' : 'print'}
              disabled={printing}
              iconSpin={!!printing}
              content="Распечатать запись"
              ml="0.5rem"
              onClick={() => act('print_record')}
            />
          }
        >
          <MedicalRecordsViewGeneral />
        </Section>
      </Stack.Item>
      {!medical || !medical.fields ? (
        <Stack.Item grow color="bad">
          <Section
            fill
            title="Медицинская информация"
            buttons={
              <Button
                icon="pen"
                content="Создать новую запись"
                onClick={() => act('new')}
              />
            }
          >
            <Stack fill>
              <Stack.Item
                bold
                grow
                textAlign="center"
                fontSize={1.75}
                align="center"
                color="label"
              >
                <Icon.Stack>
                  <Icon name="scroll" size={5} color="gray" />
                  <Icon name="slash" size={5} color="red" />
                </Icon.Stack>
                <br />
                Медицинская запись утрачена!
              </Stack.Item>
            </Stack>
          </Section>
        </Stack.Item>
      ) : (
        <>
          <Stack.Item grow>
            <Section
              fill
              scrollable
              title="Медицинская информация"
              buttons={
                <Button.Confirm
                  icon="trash"
                  disabled={!!medical.empty}
                  content="Удалить медицинскую запись"
                  onClick={() => act('del_r')}
                />
              }
            >
              <MedicalRecordsViewMedical />
            </Section>
          </Stack.Item>
          <MedicalRecordsViewComments />
        </>
      )}
    </>
  );
};

const MedicalRecordsViewGeneral = (_properties) => {
  const { data } = useBackend();
  const { general } = data;
  if (!general || !general.fields) {
    return (
      <Stack fill vertical>
        <Stack.Item grow color="bad">
          <Section fill>General records lost!</Section>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack>
      <Stack.Item grow>
        <LabeledList>
          {general.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field}>
              <Box height="20px" inline>
                {field.value}
              </Box>
              {!!field.edit && (
                <Button icon="pen" ml="0.5rem" onClick={() => doEdit(field)} />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
      {!!general.has_photos &&
        general.photos.map((p, i) => (
          <Stack.Item key={i} inline textAlign="center" color="label" ml={0}>
            <img
              src={p}
              style={{
                width: '96px',
                'margin-top': '2.5rem',
                'margin-bottom': '0.5rem',
                '-ms-interpolation-mode': 'nearest-neighbor', // TODO: Remove with 516
                'image-rendering': 'pixelated',
              }}
            />
            <br />
            Фото №{i + 1}
          </Stack.Item>
        ))}
    </Stack>
  );
};

const MedicalRecordsViewMedical = (_properties) => {
  const { act, data } = useBackend();
  const { medical } = data;
  if (!medical || !medical.fields) {
    return (
      <Stack fill vertical>
        <Stack.Item grow color="bad">
          <Section fill>Медицинская запись утрачена!</Section>
        </Stack.Item>
      </Stack>
    );
  }
  return (
    <Stack>
      <Stack.Item grow>
        <LabeledList>
          {medical.fields.map((field, i) => (
            <LabeledList.Item key={i} label={field.field} preserveWhitespace>
              {decodeHtmlEntities(field.value)}
              {!!field.edit && (
                <Button
                  icon="pen"
                  ml="0.5rem"
                  mb={field.line_break ? '1rem' : 'initial'}
                  onClick={() => doEdit(field)}
                />
              )}
            </LabeledList.Item>
          ))}
        </LabeledList>
      </Stack.Item>
    </Stack>
  );
};

const MedicalRecordsViewComments = (_properties) => {
  const { act, data } = useBackend();
  const { medical } = data;
  return (
    <Stack.Item height="150px">
      <Section
        fill
        scrollable
        title="Комментарии"
        buttons={
          <Button
            icon="comment"
            content="Добавить комментарий"
            onClick={() => modalOpen('add_comment')}
          />
        }
      >
        {medical.comments.length === 0 ? (
          <Box color="label">Комментарии отсутствуют.</Box>
        ) : (
          medical.comments.map((comment, i) => (
            <Box key={i}>
              <Box color="label" inline>
                {comment.header}
              </Box>
              <br />
              {comment.text}
              <Button
                icon="comment-slash"
                color="bad"
                ml="0.5rem"
                onClick={() => act('del_c', { del_c: i + 1 })}
              />
            </Box>
          ))
        )}
      </Section>
    </Stack.Item>
  );
};

const MedicalRecordsViruses = (_properties) => {
  const { act, data } = useBackend();
  const { virus } = data;
  const [searchText, setSearchText] = useLocalState('searchText', '');
  const [sortId2, _setSortId2] = useLocalState('sortId2', 'name');
  const [sortOrder2, _setSortOrder2] = useLocalState('sortOrder2', true);
  return (
    <>
      <Stack.Item grow>
        <Input
          ml="0.25rem"
          fluid
          placeholder="Введите Название, Количество Стадий или Тяжесть"
          onInput={(e, value) => setSearchText(value)}
        />
      </Stack.Item>
      <Stack fill vertical mt={0.5}>
        <Stack.Item grow>
          <Section fill scrollable>
            <Table className="MedicalRecords__list">
              <Table.Row bold>
                <SortButton2 id="name">Название</SortButton2>
                <SortButton2 id="max_stages">Количество стадий</SortButton2>
                <SortButton2 id="severity">Тяжесть</SortButton2>
              </Table.Row>
              {virus
                .filter(
                  createSearch(searchText, (vir) => {
                    return vir.name + '|' + vir.max_stages + '|' + vir.severity;
                  })
                )
                .sort((a, b) => {
                  const i = sortOrder2 ? 1 : -1;
                  return a[sortId2].localeCompare(b[sortId2]) * i;
                })
                .map((vir) => (
                  <Table.Row
                    key={vir.id}
                    className={'MedicalRecords__listVirus--' + vir.severity}
                    onClick={() => act('vir', { vir: vir.D })}
                  >
                    <Table.Cell>
                      <Icon name="virus" /> {vir.name}
                    </Table.Cell>
                    <Table.Cell>{vir.max_stages}</Table.Cell>
                    <Table.Cell color={severities[vir.severity]}>
                      {vir.severity}
                    </Table.Cell>
                  </Table.Row>
                ))}
            </Table>
          </Section>
        </Stack.Item>
      </Stack>
    </>
  );
};

const MedicalRecordsMedbots = (_properties) => {
  const { act, data } = useBackend();
  const { medbots } = data;
  if (medbots.length === 0) {
    return (
      <Stack.Item grow color="bad">
        <Section fill>
          <Stack fill>
            <Stack.Item
              bold
              grow
              textAlign="center"
              fontSize={1.75}
              align="center"
              color="label"
            >
              <Icon.Stack>
                <Icon name="robot" size={5} color="gray" />
                <Icon name="slash" size={5} color="red" />
              </Icon.Stack>
              <br />
              Медботы не обнаружены.
            </Stack.Item>
          </Stack>
        </Section>
      </Stack.Item>
    );
  }
  return (
    <Stack.Item grow>
      <Section fill scrollable>
        <Table className="MedicalRecords__list">
          <Table.Row bold>
            <Table.Cell>Название</Table.Cell>
            <Table.Cell>Локация</Table.Cell>
            <Table.Cell>Состояние</Table.Cell>
            <Table.Cell>Химикаты</Table.Cell>
          </Table.Row>
          {medbots.map((medbot) => (
            <Table.Row
              key={medbot.id}
              className={'MedicalRecords__listMedbot--' + medbot.on}
            >
              <Table.Cell>
                <Icon name="medical" /> {medbot.name}
              </Table.Cell>
              <Table.Cell>
                {medbot.area || 'Неизвестно'} ({medbot.x}, {medbot.y})
              </Table.Cell>
              <Table.Cell>
                {medbot.on ? (
                  <Box color="good">Включён</Box>
                ) : (
                  <Box color="average">Выключен</Box>
                )}
              </Table.Cell>
              <Table.Cell>
                {medbot.use_beaker
                  ? 'Ёмкость: ' +
                    medbot.total_volume +
                    '/' +
                    medbot.maximum_volume
                  : 'Используется внутренний синтезатор'}
              </Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Section>
    </Stack.Item>
  );
};

const SortButton = (properties) => {
  const [sortId, setSortId] = useLocalState('sortId', 'name');
  const [sortOrder, setSortOrder] = useLocalState('sortOrder', true);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        fluid
        color={sortId !== id && 'transparent'}
        onClick={() => {
          if (sortId === id) {
            setSortOrder(!sortOrder);
          } else {
            setSortId(id);
            setSortOrder(true);
          }
        }}
      >
        {children}
        {sortId === id && (
          <Icon name={sortOrder ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

const SortButton2 = (properties) => {
  const [sortId2, setSortId2] = useLocalState('sortId2', 'name');
  const [sortOrder2, setSortOrder2] = useLocalState('sortOrder2', true);
  const { id, children } = properties;
  return (
    <Table.Cell>
      <Button
        fluid
        color={sortId2 !== id && 'transparent'}
        onClick={() => {
          if (sortId2 === id) {
            setSortOrder2(!sortOrder2);
          } else {
            setSortId2(id);
            setSortOrder2(true);
          }
        }}
      >
        {children}
        {sortId2 === id && (
          <Icon name={sortOrder2 ? 'sort-up' : 'sort-down'} ml="0.25rem;" />
        )}
      </Button>
    </Table.Cell>
  );
};

const MedicalRecordsNavigation = (_properties) => {
  const { act, data } = useBackend();
  const { screen, general } = data;
  return (
    <Stack.Item m={0}>
      <Tabs>
        <Tabs.Tab
          icon="list"
          selected={screen === 2}
          onClick={() => {
            act('screen', { screen: 2 });
          }}
        >
          Просмотр записей
        </Tabs.Tab>
        <Tabs.Tab
          icon="database"
          selected={screen === 5}
          onClick={() => {
            act('screen', { screen: 5 });
          }}
        >
          База данных вирусов
        </Tabs.Tab>
        <Tabs.Tab
          icon="plus-square"
          selected={screen === 6}
          onClick={() => act('screen', { screen: 6 })}
        >
          Отслеживание медботов
        </Tabs.Tab>
        {screen === 3 && (
          <Tabs.Tab icon="wrench" selected={screen === 3}>
            Обслуживание базы данных записей
          </Tabs.Tab>
        )}
        {screen === 4 && general && !general.empty && (
          <Tabs.Tab icon="file" selected={screen === 4}>
            Запись: {general.fields[0].value}
          </Tabs.Tab>
        )}
      </Tabs>
    </Stack.Item>
  );
};

modalRegisterBodyOverride('virus', virusModalBodyOverride);
