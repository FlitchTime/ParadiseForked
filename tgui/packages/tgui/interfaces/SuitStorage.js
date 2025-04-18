import { useBackend } from '../backend';
import {
  Box,
  Button,
  Dimmer,
  Divider,
  Flex,
  Icon,
  LabeledList,
  Section,
} from '../components';
import { Window } from '../layouts';

export const SuitStorage = (props) => {
  const { data } = useBackend();
  const { uv } = data;
  return (
    <Window width={402} height={268}>
      <Window.Content display="flex" className="Layout__content--flexColumn">
        {!!uv && (
          <Dimmer backgroundColor="black" opacity={0.85}>
            <Flex>
              <Flex.Item bold textAlign="center" mb={2}>
                <Icon name="spinner" spin={1} size={4} mb={4} />
                <br />
                Disinfection of contents in progress...
              </Flex.Item>
            </Flex>
          </Dimmer>
        )}
        <StoredItems />
        <Disinfect />
      </Window.Content>
    </Window>
  );
};

const StoredItems = (props) => {
  const { act, data } = useBackend();
  const { helmet, suit, magboots, mask, storage, open, locked } = data;
  return (
    <Section
      title="Stored Items"
      flexGrow="1"
      buttons={
        <>
          <Button
            content={locked ? 'Unlock' : 'Lock'}
            icon={locked ? 'unlock' : 'lock'}
            disabled={open}
            onClick={() => act('toggle_lock')}
          />
          <Button
            content={open ? 'Close unit' : 'Open unit'}
            icon={open ? 'times-circle' : 'expand'}
            color={open ? 'red' : 'green'}
            disabled={locked}
            onClick={() => act('toggle_open')}
          />
        </>
      }
    >
      {open && !locked ? (
        <LabeledList>
          <ItemRow
            object={helmet}
            label="Helmet"
            missingText="helmet"
            eject="dispense_helmet"
          />
          <ItemRow
            object={suit}
            label="Suit"
            missingText="suit"
            eject="dispense_suit"
          />
          <ItemRow
            object={magboots}
            label="Magboots"
            missingText="magboots"
            eject="dispense_magboots"
          />
          <ItemRow
            object={mask}
            label="Breathmask"
            missingText="mask"
            eject="dispense_mask"
          />
          <ItemRow
            object={storage}
            label="Storage"
            missingText="storage item"
            eject="dispense_storage"
          />
        </LabeledList>
      ) : (
        <Flex height="100%">
          <Flex.Item
            bold
            grow="1"
            textAlign="center"
            align="center"
            color="label"
          >
            <Icon
              name={locked ? 'lock' : 'exclamation-circle'}
              size="5"
              mb={3}
            />
            <br />
            {locked ? 'The unit is locked.' : 'The unit is closed.'}
          </Flex.Item>
        </Flex>
      )}
    </Section>
  );
};

const ItemRow = (props) => {
  const { act, data } = useBackend();
  const { object, label, missingText, eject } = props;
  return (
    <LabeledList.Item label={label}>
      <Box my={0.5}>
        {object ? (
          <Button
            my={-1}
            icon="eject"
            content={object}
            onClick={() => act(eject)}
          />
        ) : (
          <Box color="silver" bold>
            No {missingText} found.
          </Box>
        )}
      </Box>
    </LabeledList.Item>
  );
};

const Disinfect = (props) => {
  const { act, data } = useBackend();
  return (
    <Section>
      <Button
        fluid
        icon="cog"
        textAlign="center"
        content="Start Disinfection Cycle"
        disabled={data.locked}
        onClick={() => act('cook')}
      />
    </Section>
  );
};
