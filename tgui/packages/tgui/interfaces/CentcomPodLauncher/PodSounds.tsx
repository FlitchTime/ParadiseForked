import { useBackend } from '../../backend';
import { Button, Section } from '../../components';
import { SOUNDS } from './constants';
import { PodLauncherData } from './types';

export const PodSounds = (props) => {
  const { act, data } = useBackend<PodLauncherData>();
  const { defaultSoundVolume, soundVolume } = data;

  return (
    <Section
      buttons={
        <Button
          color="transparent"
          icon="volume-up"
          onClick={() => act('soundVolume')}
          selected={soundVolume !== defaultSoundVolume}
          tooltip={
            `
            Громкость Зука:` + soundVolume
          }
        />
      }
      fill
      title="Звуки"
    >
      {SOUNDS.map((sound, i) => (
        <Button
          key={i}
          onClick={() => act(sound.act)}
          selected={data[sound.act]}
          tooltip={sound.tooltip}
          tooltipPosition="top-end"
        >
          {sound.title}
        </Button>
      ))}
    </Section>
  );
};
