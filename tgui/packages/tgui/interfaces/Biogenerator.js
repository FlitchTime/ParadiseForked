import { useBackend, useSharedState } from '../backend';
import {
  Button,
  Section,
  Box,
  Stack,
  Icon,
  Collapsible,
  NumberInput,
  ProgressBar,
} from '../components';
import { Window } from '../layouts';
import { Operating } from '../interfaces/common/Operating';

export const Biogenerator = (props) => {
  const { data, config } = useBackend();
  const { container, processing } = data;
  const { title } = config;
  return (
    <Window width={390} height={595}>
      <Window.Content>
        <Stack fill vertical>
          <Operating operating={processing} name={title} />
          <Storage />
          <Controls />
          <Products />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const Storage = (props) => {
  const { act, data } = useBackend();
  const {
    biomass,
    container,
    container_curr_reagents,
    container_max_reagents,
  } = data;

  return (
    <Section title="Storage">
      <Stack>
        <Stack.Item mr="20px" color="silver">
          Biomass:
        </Stack.Item>
        <Stack.Item mr="5px">{biomass}</Stack.Item>
        <Icon name="leaf" size={1.2} color="#3d8c40" />
      </Stack>
      <Stack height="21px" mt="8px" align="center">
        <Stack.Item mr="10px" color="silver">
          Container:
        </Stack.Item>
        {container ? (
          <ProgressBar
            value={container_curr_reagents}
            maxValue={container_max_reagents}
          >
            <Box textAlign="center">
              {container_curr_reagents +
                ' / ' +
                container_max_reagents +
                ' units'}
            </Box>
          </ProgressBar>
        ) : (
          <Stack.Item>None</Stack.Item>
        )}
      </Stack>
    </Section>
  );
};

const Controls = (props) => {
  const { act, data } = useBackend();
  const { has_plants, container } = data;

  return (
    <Section title="Controls">
      <Stack>
        <Stack.Item width="30%">
          <Button
            fluid
            textAlign="center"
            icon="power-off"
            disabled={!has_plants}
            tooltip={
              has_plants ? '' : 'There are no plants in the biogenerator.'
            }
            tooltipPosition="top-start"
            content="Activate"
            onClick={() => act('activate')}
          />
        </Stack.Item>
        <Stack.Item width="40%">
          <Button
            fluid
            textAlign="center"
            icon="flask"
            disabled={!container}
            tooltip={
              container ? '' : 'The biogenerator does not have a container.'
            }
            tooltipPosition="top"
            content="Detach Container"
            onClick={() => act('detach_container')}
          />
        </Stack.Item>
        <Stack.Item width="30%">
          <Button
            fluid
            textAlign="center"
            icon="eject"
            disabled={!has_plants}
            tooltip={has_plants ? '' : 'There are no stored plants to eject.'}
            tooltipPosition="top-end"
            content="Eject Plants"
            onClick={() => act('eject_plants')}
          />
        </Stack.Item>
      </Stack>
    </Section>
  );
};

const Products = (props) => {
  const { act, data } = useBackend();
  const { biomass, product_list, container } = data;

  let [vendAmount, setVendAmount] = useSharedState('vendAmount', 1);

  let content = Object.entries(product_list).map((kv, _i) => {
    let category_items = Object.entries(kv[1]).map((kv2) => {
      return kv2[1];
    });

    return (
      <Collapsible key={kv[0]} title={kv[0]} open>
        {category_items.map((item) => (
          <Stack key={item} py="2px" className="candystripe" align="center">
            <Stack.Item width="50%" ml="2px">
              {item.name}
            </Stack.Item>
            <Stack.Item textAlign="right" width="20%">
              {item.cost * vendAmount}
              <Icon ml="5px" name="leaf" size={1.2} color="#3d8c40" />
            </Stack.Item>
            <Stack.Item textAlign="right" width="40%">
              {item.needs_container && !container ? (
                <Button
                  content="No container"
                  disabled
                  icon="flask"
                  tooltip="Вставьте любой контейнер для использования этой опции"
                />
              ) : (
                <Button
                  content="Vend"
                  disabled={biomass < item.cost * vendAmount}
                  icon="arrow-circle-down"
                  onClick={() =>
                    act('create', {
                      id: item.id,
                      amount: vendAmount,
                    })
                  }
                />
              )}
            </Stack.Item>
          </Stack>
        ))}
      </Collapsible>
    );
  });

  return (
    <Section
      title="Products"
      fill
      scrollable
      height={32}
      buttons={
        <>
          <Box inline mr="5px" color="silver">
            Amount to vend:
          </Box>
          <NumberInput
            animated
            value={vendAmount}
            width="32px"
            minValue={1}
            maxValue={10}
            stepPixelSize={7}
            onChange={(e, value) => setVendAmount(value)}
          />
        </>
      }
    >
      {content}
    </Section>
  );
};
