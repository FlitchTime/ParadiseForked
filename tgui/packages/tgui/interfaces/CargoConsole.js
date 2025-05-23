import { flow } from 'common/fp';
import { filter, sortBy } from 'common/collections';
import { useBackend, useSharedState, useLocalState } from '../backend';
import {
  Button,
  LabeledList,
  Box,
  Section,
  Dropdown,
  Input,
  Table,
  Modal,
  Stack,
} from '../components';
import { Window } from '../layouts';
import { createSearch } from 'common/string';

export const CargoConsole = (props) => {
  return (
    <Window width={900} height={800}>
      <Window.Content>
        <Stack fill vertical>
          <ContentsModal />
          <StatusPane />
          <CataloguePane />
          <DetailsPane />
        </Stack>
      </Window.Content>
    </Window>
  );
};

const ContentsModal = (_properties) => {
  const [contentsModal, setContentsModal] = useLocalState(
    'contentsModal',
    null
  );

  const [contentsModalTitle, setContentsModalTitle] = useLocalState(
    'contentsModalTitle',
    null
  );
  if (contentsModal !== null && contentsModalTitle !== null) {
    return (
      <Modal
        maxWidth="75%"
        width={window.innerWidth + 'px'}
        maxHeight={window.innerHeight * 0.75 + 'px'}
        mx="auto"
      >
        <Box width="100%" bold>
          <h1>{contentsModalTitle} contents:</h1>
        </Box>
        <Box>
          {contentsModal.map((i) => (
            // This needs keying. I hate it.
            <Box key={i}>- {i}</Box>
          ))}
        </Box>
        <Box m={2}>
          <Button
            content="Close"
            onClick={() => {
              setContentsModal(null);
              setContentsModalTitle(null);
            }}
          />
        </Box>
      </Modal>
    );
  } else {
    return;
  }
};

const StatusPane = (_properties) => {
  const { act, data } = useBackend();
  const { is_public, points, credits, timeleft, moving, at_station } = data;

  // Shuttle status text
  let statusText;
  let shuttleButtonText;
  if (!moving && !at_station) {
    statusText = 'Docked off-station';
    shuttleButtonText = 'Call Shuttle';
  } else if (!moving && at_station) {
    statusText = 'Docked at the station';
    shuttleButtonText = 'Return Shuttle';
  } else if (moving) {
    // Yes I am this fussy that it goes plural
    shuttleButtonText = 'In Transit...';
    if (timeleft !== 1) {
      statusText = 'Shuttle is en route (ETA: ' + timeleft + ' minutes)';
    } else {
      statusText = 'Shuttle is en route (ETA: ' + timeleft + ' minute)';
    }
  }

  return (
    <Stack.Item>
      <Section title="Status">
        <LabeledList>
          <LabeledList.Item label="Points Available">{points}</LabeledList.Item>
          <LabeledList.Item label="Credits Available">
            {credits}
          </LabeledList.Item>
          <LabeledList.Item label="Shuttle Status">
            {statusText}
          </LabeledList.Item>
          {is_public === 0 && (
            <LabeledList.Item label="Controls">
              <Button
                content={shuttleButtonText}
                disabled={moving}
                onClick={() => act('moveShuttle')}
              />
              <Button
                content="View Central Command Messages"
                onClick={() => act('showMessages')}
              />
            </LabeledList.Item>
          )}
        </LabeledList>
      </Section>
    </Stack.Item>
  );
};

const CataloguePane = (_properties) => {
  const { act, data } = useBackend();
  const { categories, supply_packs } = data;

  const [category, setCategory] = useSharedState('category', 'Emergency');

  const [searchText, setSearchText] = useSharedState('search_text', '');

  const [contentsModal, setContentsModal] = useLocalState(
    'contentsModal',
    null
  );

  const [contentsModalTitle, setContentsModalTitle] = useLocalState(
    'contentsModalTitle',
    null
  );

  const packSearch = createSearch(searchText, (crate) => crate.name);

  const cratesToShow = flow([
    filter(
      (pack) =>
        pack.cat ===
          categories.filter((c) => c.name === category)[0].category ||
        searchText
    ),
    searchText && filter(packSearch),
    sortBy((pack) => pack.name.toLowerCase()),
  ])(supply_packs);

  let titleText = 'Crate Catalogue';
  if (searchText) {
    titleText = "Results for '" + searchText + "':";
  } else if (category) {
    titleText = 'Browsing ' + category;
  }
  return (
    <Stack.Item>
      <Section
        title={titleText}
        buttons={
          <Dropdown
            width="190px"
            options={categories.map((r) => r.name)}
            selected={category}
            onSelected={(val) => setCategory(val)}
          />
        }
      >
        <Input
          fluid
          placeholder="Search for..."
          onInput={(e, v) => setSearchText(v)}
          mb={1}
        />
        <Box maxHeight={25} overflowY="auto" overflowX="hidden">
          <Table m="0.5rem">
            {cratesToShow.map((c) => (
              <Table.Row key={c.name}>
                <Table.Cell bold>
                  <Box color={c.has_sale ? 'good' : 'default'}>
                    {c.name} ({c.cost ? c.cost + ' Points' : ''}
                    {c.creditsCost && c.cost ? ' ' : ''}
                    {c.creditsCost ? c.creditsCost + ' Credits' : ''})
                  </Box>
                </Table.Cell>
                <Table.Cell textAlign="right" pr={1}>
                  <Button
                    content="Order 1"
                    icon="shopping-cart"
                    onClick={() =>
                      act('order', {
                        crate: c.ref,
                        multiple: 0,
                      })
                    }
                  />
                  <Button
                    content="Order Multiple"
                    icon="cart-plus"
                    onClick={() =>
                      act('order', {
                        crate: c.ref,
                        multiple: 1,
                      })
                    }
                  />
                  <Button
                    content="View Contents"
                    icon="search"
                    onClick={() => {
                      setContentsModal(c.contents);
                      setContentsModalTitle(c.name);
                    }}
                  />
                </Table.Cell>
              </Table.Row>
            ))}
          </Table>
        </Box>
      </Section>
    </Stack.Item>
  );
};

const DetailsPane = (_properties) => {
  const { act, data } = useBackend();
  const { requests, canapprove, orders } = data;
  return (
    <Section fill scrollable title="Details">
      <Box bold>Requests</Box>
      <Table m="0.5rem">
        {requests.map((r) => (
          <Table.Row key={r.ordernum}>
            <Table.Cell>
              <Box>
                - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
              </Box>
              <Box italic>Reason: {r.comment}</Box>
              <Box italic>Required Techs: {r.pack_techs}</Box>
            </Table.Cell>
            <Stack.Item textAlign="right">
              <Button
                content="Approve"
                color="green"
                disabled={!canapprove}
                onClick={() =>
                  act('approve', {
                    ordernum: r.ordernum,
                  })
                }
              />
              <Button
                content="Deny"
                color="red"
                onClick={() =>
                  act('deny', {
                    ordernum: r.ordernum,
                  })
                }
              />
            </Stack.Item>
          </Table.Row>
        ))}
      </Table>
      <Box bold>Confirmed Orders</Box>
      <Table m="0.5rem">
        {orders.map((r) => (
          <Table.Row key={r.ordernum}>
            <Table.Cell>
              <Box>
                - #{r.ordernum}: {r.supply_type} for <b>{r.orderedby}</b>
              </Box>
              <Box italic>Reason: {r.comment}</Box>
            </Table.Cell>
          </Table.Row>
        ))}
      </Table>
    </Section>
  );
};
