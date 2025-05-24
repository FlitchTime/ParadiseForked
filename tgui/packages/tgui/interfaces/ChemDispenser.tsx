import { useBackend } from '../backend';
import {
  Box,
  Button,
  Stack,
  LabeledList,
  ProgressBar,
  Section,
} from '../components';
import { BeakerContents } from '../interfaces/common/BeakerContents';
import { Window } from '../layouts';

const dispenseAmounts = [1, 5, 10, 20, 30, 50, 100];
const removeAmounts = [1, 5, 10];

type DispenserChemical = {
  id: string;
  title: string;
  reagentColor: string;
};

type ChemDispenserData = {
  chemicals: DispenserChemical[];
  amount: number;
  energy: number;
  maxEnergy: number;
  glass: boolean;
};

export const ChemDispenser = (props: unknown) => {
  const { data } = useBackend<ChemDispenserData>();
  const { chemicals } = data;
  return (
    <Window width={460} height={400 + chemicals.length * 8}>
      <Window.Content>
        <Stack fill vertical>
          <ChemDispenserSettings />
          <ChemDispenserChemicals />
          <ChemDispenserBeaker />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ChemDispenserSettings = (properties) => {
  const { act, data } = useBackend<ChemDispenserData>();
  const { amount, energy, maxEnergy } = data;
  return (
    <Stack.Item>
      <Section title="Параметры">
        <LabeledList>
          <LabeledList.Item label="Энергия">
            <ProgressBar
              value={energy}
              minValue={0}
              maxValue={maxEnergy}
              ranges={{
                good: [maxEnergy * 0.5, Infinity],
                average: [maxEnergy * 0.25, maxEnergy * 0.5],
                bad: [-Infinity, maxEnergy * 0.25],
              }}
            >
              {energy} / {maxEnergy} единиц
            </ProgressBar>
          </LabeledList.Item>
          <LabeledList.Item label="Объём синтеза" verticalAlign="middle">
            <Stack>
              {dispenseAmounts.map((a, i) => (
                <Stack.Item key={i} grow width="15%">
                  <Button
                    fluid
                    icon="cog"
                    selected={amount === a}
                    onClick={() =>
                      act('amount', {
                        amount: a,
                      })
                    }
                  >
                    {a}
                  </Button>
                </Stack.Item>
              ))}
            </Stack>
          </LabeledList.Item>
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const ChemDispenserChemicals = (properties) => {
  const { act, data } = useBackend<ChemDispenserData>();
  const { chemicals = [] } = data;
  const flexFillers = [];
  for (let i = 0; i < (chemicals.length + 1) % 3; i++) {
    flexFillers.push(true);
  }
  return (
    <Stack.Item grow>
      <Section
        fill
        scrollable
        title={data.glass ? 'Синтез напитков' : 'Синтез реагентов'}
      >
        {chemicals.map((chemical, i) => (
          <Button
            m={0.1}
            key={i}
            width="32.5%"
            icon="tint"
            iconColor={chemical.reagentColor}
            overflow="hidden"
            style={{ marginLeft: '2px', textOverflow: 'ellipsis' }}
            onClick={() =>
              act('dispense', {
                reagent: chemical.id,
              })
            }
          >
            {chemical.title}
          </Button>
        ))}
        {flexFillers.map((_, i) => (
          <Stack.Item key={i} grow basis="25%" />
        ))}
      </Section>
    </Stack.Item>
  );
};

const ChemDispenserBeaker = (properties) => {
  const { act, data } = useBackend<BeakerData>();
  const {
    isBeakerLoaded,
    beakerCurrentVolume,
    beakerMaxVolume,
    beakerContents = [],
  } = data;
  return (
    <Stack.Item height={16}>
      <Section
        title="Ёмкость"
        fill
        scrollable
        buttons={
          <Box>
            {!!isBeakerLoaded && (
              <Box inline color="label" mr={2}>
                {beakerCurrentVolume} / {beakerMaxVolume} единиц
              </Box>
            )}
            <Button
              icon="eject"
              disabled={!isBeakerLoaded}
              onClick={() => act('ejectBeaker')}
            >
              Извлечь
            </Button>
          </Box>
        }
      >
        <BeakerContents
          beakerLoaded={isBeakerLoaded}
          beakerContents={beakerContents}
          buttons={(chemical) => (
            <>
              <Button
                tooltip={
                  'Удаляет лишнее, округляя объём до ' +
                  Math.trunc(chemical.volume)
                }
                icon="arrow-circle-down"
                onClick={() =>
                  act('remove', {
                    reagent: chemical.id,
                    amount: -2,
                  })
                }
              />
              {removeAmounts.map((a, i) => (
                <Button
                  key={i}
                  onClick={() =>
                    act('remove', {
                      reagent: chemical.id,
                      amount: a,
                    })
                  }
                >
                  {a}
                </Button>
              ))}
              <Button
                tooltip={'Удаляет остальные реагенты'}
                icon="compress-arrows-alt"
                onClick={() =>
                  act('remove', {
                    reagent: chemical.id,
                    amount: -1,
                  })
                }
              />
              <Button
                tooltip={'Удаляет этот реагент'}
                icon="droplet-slash"
                onClick={() =>
                  act('remove', {
                    reagent: chemical.id,
                    amount: chemical.volume,
                  })
                }
              />
            </>
          )}
        />
      </Section>
    </Stack.Item>
  );
};
