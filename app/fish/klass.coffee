'use strict'
pi = require '../core'
require '../components'
utils = pi.utils

# extend core klasses
utils.extend(
  pi.klass,
  SCROLL_CONTENT: 'pi-scroll-content'
  SCROLL_PANE: 'pi-scroll-pane'
  SCROLL_TRACK: 'pi-scroll-track'
  SCROLL_THUMB: 'pi-scroll-thumb'
  HAS_SCROLLER: 'has-scroller'
  POPUP_OVERLAY: 'pi-overlay'
  POPUP_CONTAINER: 'pi-popup-container'
  POPUP: 'pi-popup'
  POPUP_NO_CLOSE: 'no-close'
  SORTER_DESC: 'is-desc'
  SORDER_ASC: 'is-asc'
  )