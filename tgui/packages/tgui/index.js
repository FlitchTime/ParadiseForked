/**
 * @file
 * @copyright 2020 Aleksej Komarov
 * @license MIT
 */

// Themes
import './styles/main.scss';
import './styles/themes/abductor.scss';
import './styles/themes/cardtable.scss';
import './styles/themes/changeling.scss';
import './styles/themes/clockwork.scss';
import './styles/themes/hackerman.scss';
import './styles/themes/hydroponics.scss';
import './styles/themes/malfunction.scss';
import './styles/themes/ntos.scss';
import './styles/themes/ntos_cat.scss';
import './styles/themes/ntos_darkmode.scss';
import './styles/themes/ntos_lightmode.scss';
import './styles/themes/ntos_spooky.scss';
import './styles/themes/ntos_terminal.scss';
import './styles/themes/ntos_roboquest.scss';
import './styles/themes/ntos_roboblue.scss';
import './styles/themes/ntOS95.scss';
import './styles/themes/paper.scss';
import './styles/themes/retro.scss';
import './styles/themes/safe.scss';
import './styles/themes/securestorage.scss';
import './styles/themes/security.scss';
import './styles/themes/spider_clan.scss';
import './styles/themes/syndicate.scss';
import './styles/themes/nologo.scss';
import './styles/themes/spider_clan.scss';
import './styles/themes/ntOS95.scss';

import { perf } from 'common/perf';
import { setupHotReloading } from 'tgui-dev-server/link/client.cjs';
import { setupHotKeys } from './hotkeys';
import { loadIconRefMap } from './icons';
import { captureExternalLinks } from './links';
import { createRenderer } from './renderer';
import { configureStore } from './store';
import { setupGlobalEvents } from './events';
import { setGlobalStore } from './backend';

perf.mark('inception', window.performance?.timing?.navigationStart);
perf.mark('init');

const store = configureStore();

const renderApp = createRenderer(() => {
  loadIconRefMap();
  setGlobalStore(store);
  const { getRoutedComponent } = require('./routes');
  const Component = getRoutedComponent(store);
  return <Component />;
});

const setupApp = () => {
  // Delay setup
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', setupApp);
    return;
  }

  setupGlobalEvents();
  setupHotKeys();
  captureExternalLinks();

  // Re-render UI on store updates
  store.subscribe(renderApp);

  // Dispatch incoming messages as store actions
  Byond.subscribe((type, payload) => store.dispatch({ type, payload }));

  // Enable hot module reloading
  if (module.hot) {
    setupHotReloading();
    module.hot.accept(
      ['./components', './debug', './layouts', './routes'],
      () => {
        renderApp();
      }
    );
  }
};

setupApp();
