import { classes } from 'common/react';
import { useBackend } from '../../backend';
import { Box, Button, Dimmer, Section, Stack, Flex } from '../../components';

type PrimaryObjectiveMenuProps = {
  primary_objectives;
  can_renegotiate;
};

export const PrimaryObjectiveMenu = (props: PrimaryObjectiveMenuProps) => {
  const { act } = useBackend();
  const { primary_objectives, can_renegotiate } = props;
  return (
    <Section fill scrollable align="center">
      <Box my={4} bold fontSize={1.2} color="green">
        WELCOME, AGENT.
      </Box>
      <Box my={4} bold fontSize={1.2}>
        Your objectives are as follows. Complete these at all costs.
      </Box>
      <Stack vertical>
        {primary_objectives.map((prim_obj, index) => (
          <Flex direction="column">
            <Flex.Item basis="content">
              <Box
                className={classes([
                  'UplinkObjective__Titlebar',
                  index === primary_objectives.length - 1
                    ? 'reputation-good'
                    : 'reputation-very-good',
                ])}
                width="100%"
                height="100%"
              >
                <Stack>
                  <Stack.Item grow={1}>{prim_obj['task_name']}</Stack.Item>
                </Stack>
              </Box>
            </Flex.Item>
            <Flex.Item basis="content">
              <Box className="UplinkObjective__Content" height="100%">
                <Box>{prim_obj['task_text']}</Box>
              </Box>
            </Flex.Item>
            <Flex.Item>
              <Box className="UplinkObjective__Footer" />
            </Flex.Item>
          </Flex>
        ))}
      </Stack>
      {!!can_renegotiate && (
        <Box mt={3} mb={5} bold fontSize={1.2} align="center" color="white">
          <Button
            content={'Renegotiate Contract'}
            tooltip={
              'Replace your existing primary objectives with a custom one. This action can only be performed once.'
            }
            onClick={() => act('renegotiate_objectives')}
          />
        </Box>
      )}
      <Box my={4} fontSize={0.8}>
        <Box>SyndOS Version 3.17</Box>
        <Box color="green">Connection Secure</Box>
      </Box>
    </Section>
  );
};
