import { round } from 'common/math';
import { capitalize } from 'common/string';
import { useBackend } from '../backend';
import {
  AnimatedNumber,
  Box,
  Button,
  Icon,
  LabeledList,
  ProgressBar,
  Section,
  Stack,
  Table,
  Tooltip,
} from '../components';
import { Window } from '../layouts';

const stats = [
  ['good', 'Норма'],
  ['average', 'Критическое состояние'],
  ['bad', 'Зафиксирована смерть'],
];

const abnormalities = [
  [
    'hasBorer',
    'bad',
    'В лобной доле обнаружено крупное образование,' +
      ' возможно, злокачественное. Рекомендуется хирургическое удаление.',
  ],
  ['hasVirus', 'bad', 'Обнаружен вирус в кровотоке пациента.'],
  ['blind', 'average', 'Обнаружена катаракта.'],
  ['colourblind', 'average', 'Обнаружены нарушения в работе фоторецепторов'],
  ['nearsighted', 'average', 'Обнаружено смещение сетчатки.'],
];

const damages = [
  ['Удушье', 'oxyLoss'],
  ['Повреждение мозга', 'brainLoss'],
  ['Отравление', 'toxLoss'],
  ['Радиационное поражение', 'radLoss'],
  ['Механические повреждения', 'bruteLoss'],
  ['Генетические повреждения', 'cloneLoss'],
  ['Термические повреждения', 'fireLoss'],
  ['Паралич тела', 'paralysis'],
];

const damageRange = {
  average: [0.25, 0.5],
  bad: [0.5, Infinity],
};

const mapTwoByTwo = (a, c) => {
  let result = [];
  for (let i = 0; i < a.length; i += 2) {
    result.push(c(a[i], a[i + 1], i));
  }
  return result;
};

const reduceOrganStatus = (A) => {
  return A.length > 0
    ? A.filter((s) => !!s).reduce(
        (a, s) => (
          <>
            {a}
            <Box key={s}>{s}</Box>
          </>
        ),
        null
      )
    : null;
};

const germStatus = (i) => {
  if (i > 100) {
    if (i < 300) {
      return 'Лёгкая инфекция';
    }
    if (i < 400) {
      return 'Лёгкая инфекция+';
    }
    if (i < 500) {
      return 'Лёгкая инфекция++';
    }
    if (i < 700) {
      return 'Острая инфекция';
    }
    if (i < 800) {
      return 'Острая инфекция+';
    }
    if (i < 900) {
      return 'Острая инфекция++';
    }
    if (i >= 900) {
      return 'Сепсис';
    }
  }

  return '';
};

export const BodyScanner = (props) => {
  const { data } = useBackend();
  const { occupied, occupant = {} } = data;
  const body = occupied ? (
    <BodyScannerMain occupant={occupant} />
  ) : (
    <BodyScannerEmpty />
  );
  return (
    <Window width={700} height={600} title="Медицинский сканер">
      <Window.Content scrollable>{body}</Window.Content>
    </Window>
  );
};

const BodyScannerMain = (props) => {
  const { occupant } = props;
  return (
    <Box>
      <BodyScannerMainOccupant occupant={occupant} />
      <BodyScannerMainAbnormalities occupant={occupant} />
      <BodyScannerMainDamage occupant={occupant} />
      <BodyScannerMainOrgansExternal organs={occupant.extOrgan} />
      <BodyScannerMainOrgansInternal organs={occupant.intOrgan} />
    </Box>
  );
};

const BodyScannerMainOccupant = (props) => {
  const { act, data } = useBackend();
  const { occupant } = data;
  return (
    <Section
      title="Пациент"
      buttons={
        <>
          <Button icon="print" onClick={() => act('print_p')}>
            Распечатать отчёт
          </Button>
          <Button icon="print" onClick={() => act('insurance')}>
            Списать страховку
          </Button>
          <Button icon="user-slash" onClick={() => act('eject_id')}>
            Извлечь карту
          </Button>
          <Button icon="user-slash" onClick={() => act('ejectify')}>
            Извлечь пациента
          </Button>
        </>
      }
    >
      <LabeledList>
        <LabeledList.Item label="Имя">{occupant.name}</LabeledList.Item>
        <LabeledList.Item label="Оценка здоровья">
          <ProgressBar
            min="0"
            max={occupant.maxHealth}
            value={occupant.health / occupant.maxHealth}
            ranges={{
              good: [0.5, Infinity],
              average: [0, 0.5],
              bad: [-Infinity, 0],
            }}
          />
        </LabeledList.Item>
        <LabeledList.Item label="Состояние" color={stats[occupant.stat][0]}>
          {stats[occupant.stat][1]}
        </LabeledList.Item>
        <LabeledList.Item label="Температура тела">
          <AnimatedNumber value={round(occupant.bodyTempC)} />
          &deg;C,&nbsp;
          <AnimatedNumber value={round(occupant.bodyTempF)} />
          &deg;F
        </LabeledList.Item>
        <LabeledList.Item label="Импланты">
          {occupant.implant_len ? (
            <Box>{occupant.implant.map((im) => im.name).join(', ')}</Box>
          ) : (
            <Box color="label">Отсутствуют</Box>
          )}
        </LabeledList.Item>
      </LabeledList>
    </Section>
  );
};

const BodyScannerMainAbnormalities = (props) => {
  const { occupant } = props;
  if (
    !(
      occupant.hasBorer ||
      occupant.blind ||
      occupant.colourblind ||
      occupant.nearsighted ||
      occupant.hasVirus
    )
  ) {
    return (
      <Section title="Отклонения">
        <Box color="label">Никаких отклонений от нормы не обнаружено.</Box>
      </Section>
    );
  }

  return (
    <Section title="Отклонения">
      {abnormalities.map((a, i) => {
        if (occupant[a[0]]) {
          return (
            <Box key={a[2]} color={a[1]} bold={a[1] === 'bad'}>
              {a[2]}
            </Box>
          );
        }
      })}
    </Section>
  );
};

const BodyScannerMainDamage = (props) => {
  const { occupant } = props;
  return (
    <Section title="Общий урон">
      <Table>
        {mapTwoByTwo(damages, (d1, d2, i) => (
          <>
            <Table.Row color="label">
              <Table.Cell>{d1[0]}:</Table.Cell>
              <Table.Cell>{!!d2 && d2[0] + ':'}</Table.Cell>
            </Table.Row>
            <Table.Row>
              <Table.Cell>
                <BodyScannerMainDamageBar
                  value={occupant[d1[1]]}
                  marginBottom={i < damages.length - 2}
                />
              </Table.Cell>
              <Table.Cell>
                {!!d2 && <BodyScannerMainDamageBar value={occupant[d2[1]]} />}
              </Table.Cell>
            </Table.Row>
          </>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainDamageBar = (props) => {
  return (
    <ProgressBar
      min="0"
      max="100"
      value={props.value / 100}
      mt="0.5rem"
      mb={!!props.marginBottom && '0.5rem'}
      ranges={damageRange}
    >
      {round(props.value)}
    </ProgressBar>
  );
};

const BodyScannerMainOrgansExternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="Внешние органы">
        <Box color="label">Н/Д</Box>
      </Section>
    );
  }

  return (
    <Section title="Внешние органы">
      <Table>
        <Table.Row header>
          <Table.Cell>Название</Table.Cell>
          <Table.Cell textAlign="center">Общий урон</Table.Cell>
          <Table.Cell textAlign="right">Травмы</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}>
            <Table.Cell
              color={
                (!!o.status.dead && 'bad') ||
                ((!!o.internalBleeding ||
                  !!o.burnWound ||
                  !!o.lungRuptured ||
                  !!o.status.broken ||
                  !!o.open ||
                  o.germ_level > 100) &&
                  'average') ||
                (!!o.status.robotic && 'label')
              }
              width="33%"
            >
              {capitalize(o.name)}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                m={-0.5}
                min="0"
                max={o.maxHealth}
                mt={i > 0 && '0.5rem'}
                value={o.totalLoss / o.maxHealth}
                ranges={damageRange}
              >
                <Stack>
                  <Tooltip content="Общий урон">
                    <Stack.Item>
                      <Icon name="heartbeat" mr={0.5} />
                      {round(o.totalLoss)}
                    </Stack.Item>
                  </Tooltip>
                  {!!o.bruteLoss && (
                    <Tooltip content="Механические повреждения">
                      <Stack.Item grow>
                        <Icon name="bone" mr={0.5} />
                        {round(o.bruteLoss)}
                      </Stack.Item>
                    </Tooltip>
                  )}
                  {!!o.fireLoss && (
                    <Tooltip content="Термические повреждения">
                      <Stack.Item>
                        <Icon name="fire" mr={0.5} />
                        {round(o.fireLoss)}
                      </Stack.Item>
                    </Tooltip>
                  )}
                </Stack>
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && 'calc(0.5rem + 2px)'}
            >
              <Box color="average" inline>
                {reduceOrganStatus([
                  !!o.internalBleeding && 'Внутреннее кровотечение',
                  !!o.burnWound && 'Критические ожоги тканей',
                  !!o.lungRuptured && 'Пробито лёгкое',
                  !!o.status.broken && o.status.broken,
                  germStatus(o.germ_level),
                  !!o.open && 'Открытый разрез',
                ])}
              </Box>
              <Box inline>
                {reduceOrganStatus([
                  !!o.status.splinted && <Box color="good">Наложена шина</Box>,
                  !!o.status.robotic && <Box color="label">Синтетическое</Box>,
                  !!o.status.dead && (
                    <Box color="bad" bold>
                      Мертво
                    </Box>
                  ),
                ])}
                {reduceOrganStatus(
                  o.shrapnel.map((s) => (s.known ? s.name : 'Инородное тело'))
                )}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerMainOrgansInternal = (props) => {
  if (props.organs.length === 0) {
    return (
      <Section title="Внутренние органы">
        <Box color="label">Н/Д</Box>
      </Section>
    );
  }

  return (
    <Section title="Внутренние органы">
      <Table>
        <Table.Row header>
          <Table.Cell>Название</Table.Cell>
          <Table.Cell textAlign="center">Общий урон</Table.Cell>
          <Table.Cell textAlign="right">Травмы</Table.Cell>
        </Table.Row>
        {props.organs.map((o, i) => (
          <Table.Row key={i}>
            <Table.Cell
              color={
                (!!o.dead && 'bad') ||
                (o.germ_level > 100 && 'average') ||
                (o.robotic > 0 && 'label')
              }
              width="33%"
            >
              {capitalize(o.name)}
            </Table.Cell>
            <Table.Cell textAlign="center">
              <ProgressBar
                min="0"
                max={o.maxHealth}
                value={o.damage / o.maxHealth}
                mt={i > 0 && '0.5rem'}
                ranges={damageRange}
              >
                {round(o.damage)}
              </ProgressBar>
            </Table.Cell>
            <Table.Cell
              textAlign="right"
              verticalAlign="top"
              width="33%"
              pt={i > 0 && 'calc(0.5rem + 2px)'}
            >
              <Box color="average" inline>
                {reduceOrganStatus([germStatus(o.germ_level)])}
              </Box>
              <Box inline>
                {reduceOrganStatus([
                  o.robotic === 1 && <Box color="label">Синтетическое</Box>,
                  o.robotic === 2 && <Box color="label">Синтетическое</Box>,
                  !!o.dead && (
                    <Box color="bad" bold>
                      Мертво
                    </Box>
                  ),
                ])}
              </Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};

const BodyScannerEmpty = () => {
  return (
    <Section fill>
      <Stack fill textAlign="center">
        <Stack.Item grow align="center" color="label">
          <Icon name="user-slash" mb="0.5rem" size="5" />
          <br />
          Пациент внутри не обнаружен.
        </Stack.Item>
      </Stack>
    </Section>
  );
};
