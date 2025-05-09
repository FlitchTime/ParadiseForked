import { useBackend } from '../backend';
import {
  Button,
  LabeledList,
  Section,
  Box,
  Table,
  ProgressBar,
} from '../components';
import { LabeledListItem } from '../components/LabeledList';
import { Window } from '../layouts';

export const SyndicateComputerSimple = (props) => {
  const { act, data } = useBackend();
  return (
    <Window width={400} height={400} theme="syndicate">
      <Window.Content>
        {data.rows.map((record) => (
          <Section
            key={record.title}
            title={record.title}
            buttons={
              <Button
                content={record.buttontitle}
                disabled={record.buttondisabled}
                tooltip={record.buttontooltip}
                tooltipPosition="left"
                onClick={() => act(record.buttonact)}
              />
            }
          >
            {record.status}
            {!!record.bullets && (
              <Box>
                {record.bullets.map((bullet) => (
                  <Box key={bullet}>{bullet}</Box>
                ))}
              </Box>
            )}
          </Section>
        ))}
      </Window.Content>
    </Window>
  );
};
