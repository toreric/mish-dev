import { cell, resource } from 'ember-resources';

const aTime = new Intl.DateTimeFormat('sv-SE', {
  hour: 'numeric',
  minute: 'numeric',
  second: 'numeric',
  hour12: false,
  timeZone: "Europe/Stockholm",
  timeZoneName: "long",
});

export const Clock = resource(({ on }) => {
  let time = cell(new Date());
  let interval = setInterval(() => (time.current = new Date()), 1000);

  on.cleanup(() => clearInterval(interval));

  return () => aTime.format(time.current);
});
