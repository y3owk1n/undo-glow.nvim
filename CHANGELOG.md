# Changelog

## [1.6.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.5.0...v1.6.0) (2025-03-02)


### Features

* **animation:** add fade_reverse animation ([#178](https://github.com/y3owk1n/undo-glow.nvim/issues/178)) ([698bc9f](https://github.com/y3owk1n/undo-glow.nvim/commit/698bc9fa50feaa56c9d867f89c2e24df26b2f52c))
* **animation:** add rainbow animation ([#172](https://github.com/y3owk1n/undo-glow.nvim/issues/172)) ([534f0b6](https://github.com/y3owk1n/undo-glow.nvim/commit/534f0b603d401758e5ad7530de22bd0ce5eb222c))
* **animation:** add slide animation ([#173](https://github.com/y3owk1n/undo-glow.nvim/issues/173)) ([7e6d87a](https://github.com/y3owk1n/undo-glow.nvim/commit/7e6d87a3603633a5e172e22bd9f9fc0278faf2b4))
* **animation:** add slide_reverse animation ([#174](https://github.com/y3owk1n/undo-glow.nvim/issues/174)) ([e8b8fad](https://github.com/y3owk1n/undo-glow.nvim/commit/e8b8fad30ed2a3fa1e03ca5fb8e9331b2b946718))
* **animation:** allow abort current animation and fallback to default ([#171](https://github.com/y3owk1n/undo-glow.nvim/issues/171)) ([0d1fb1c](https://github.com/y3owk1n/undo-glow.nvim/commit/0d1fb1c40fd69e9f3ea4357f413ac23a381a5d3a))
* **animation:** allow animate_fn to return nil ([#170](https://github.com/y3owk1n/undo-glow.nvim/issues/170)) ([adc3f43](https://github.com/y3owk1n/undo-glow.nvim/commit/adc3f43e801bd3ca265a788e524a2d0d54a78ca2))


### Bug Fixes

* add priority to work properly with render-markdown.nvim ([#166](https://github.com/y3owk1n/undo-glow.nvim/issues/166)) ([80ddfce](https://github.com/y3owk1n/undo-glow.nvim/commit/80ddfce3dde741695ac8bd4e6a5a5f884201c96c))
* **animation.slide:** abort animation when multiple lines ([#175](https://github.com/y3owk1n/undo-glow.nvim/issues/175)) ([1b67f73](https://github.com/y3owk1n/undo-glow.nvim/commit/1b67f73ad47b28ca176c8b555a09db91e6a0795a))

## [1.5.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.4.0...v1.5.0) (2025-02-28)


### Features

* **animation:** add desaturate animation ([#155](https://github.com/y3owk1n/undo-glow.nvim/issues/155)) ([46c98be](https://github.com/y3owk1n/undo-glow.nvim/commit/46c98bee10e9249e5988cdbc442f05ebbcd26b94))
* **animation:** add spring animation ([#154](https://github.com/y3owk1n/undo-glow.nvim/issues/154)) ([cbfec8c](https://github.com/y3owk1n/undo-glow.nvim/commit/cbfec8c0177a071bb327ca7333456eb2962bd916))
* **animation:** add strobe animation ([#156](https://github.com/y3owk1n/undo-glow.nvim/issues/156)) ([5b454e8](https://github.com/y3owk1n/undo-glow.nvim/commit/5b454e843bf4506a768109813f8018ea715b05f9))
* **animation:** add zoom animation ([#157](https://github.com/y3owk1n/undo-glow.nvim/issues/157)) ([52cbe7b](https://github.com/y3owk1n/undo-glow.nvim/commit/52cbe7bbda2933f7bf29777ab951f9934548f8df))
* **animation:** simplify animation color creation ([#162](https://github.com/y3owk1n/undo-glow.nvim/issues/162)) ([fa6f20f](https://github.com/y3owk1n/undo-glow.nvim/commit/fa6f20f0aacd749455225f8022e3984c429f8a1b))
* **color:** add rgb to hsl conversion ([#152](https://github.com/y3owk1n/undo-glow.nvim/issues/152)) ([48350f3](https://github.com/y3owk1n/undo-glow.nvim/commit/48350f387a9c783226511794f9b275a50904e0f3))


### Bug Fixes

* **animation.animate.pulse:** improve pulse effect to stimulate realistic pulse ([#151](https://github.com/y3owk1n/undo-glow.nvim/issues/151)) ([32cd757](https://github.com/y3owk1n/undo-glow.nvim/commit/32cd757a97e04f0d90dbe5b8fd3ccf48b07d0609))
* **animation:** call M.animate_clear properly ([#163](https://github.com/y3owk1n/undo-glow.nvim/issues/163)) ([bb86fc6](https://github.com/y3owk1n/undo-glow.nvim/commit/bb86fc652e3ffe80cd32a0d7579332729740fc27))
* **commands.cursor_moved:** do not default prev_buf and prev_win to current on load ([#143](https://github.com/y3owk1n/undo-glow.nvim/issues/143)) ([a101421](https://github.com/y3owk1n/undo-glow.nvim/commit/a1014219c787a5c506ab62a54bde61b2ee1ab1bf))
* **commands.cursor_moved:** full width for cursor highlight ([#146](https://github.com/y3owk1n/undo-glow.nvim/issues/146)) ([c8158ce](https://github.com/y3owk1n/undo-glow.nvim/commit/c8158ce7b594b2cb5f735ed394850819cd6fbea1))
* ensure that force_edge are properly checked as nil before default to boolean ([#145](https://github.com/y3owk1n/undo-glow.nvim/issues/145)) ([d18fe70](https://github.com/y3owk1n/undo-glow.nvim/commit/d18fe7082abf386356baa76c627572566ef5e04f))

## [1.4.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.3.0...v1.4.0) (2025-02-27)


### Features

* add force_edge options for highlighting ([#128](https://github.com/y3owk1n/undo-glow.nvim/issues/128)) ([db2674a](https://github.com/y3owk1n/undo-glow.nvim/commit/db2674adef05577f37916b2fd48429132871b9c4))
* **animation:** add ability to use default animation or custom function ([#121](https://github.com/y3owk1n/undo-glow.nvim/issues/121)) ([fe37b56](https://github.com/y3owk1n/undo-glow.nvim/commit/fe37b56985f9b671c8fc1a545df63c7b97a757a0))
* **command:** add significant cursor moved command similar to beacon.nvim ([#129](https://github.com/y3owk1n/undo-glow.nvim/issues/129)) ([41d18d8](https://github.com/y3owk1n/undo-glow.nvim/commit/41d18d8e2e7751d66d458942c20d34773adb95c5))


### Bug Fixes

* **color.hex_to_rgb:** support 3 character hex transformation ([#135](https://github.com/y3owk1n/undo-glow.nvim/issues/135)) ([4ea7e69](https://github.com/y3owk1n/undo-glow.nvim/commit/4ea7e6937b36a7ab9e470521145140df7847b649))
* **command.cursor_moved:** ignore cursor_moved when doing search operations ([#133](https://github.com/y3owk1n/undo-glow.nvim/issues/133)) ([6b97533](https://github.com/y3owk1n/undo-glow.nvim/commit/6b975336cf0d778e0d006ef7b34c386c622cb3b2))
* **commands.cursor_moved:** ignore optional file types and also only run on text buffers ([#140](https://github.com/y3owk1n/undo-glow.nvim/issues/140)) ([55512c0](https://github.com/y3owk1n/undo-glow.nvim/commit/55512c0399986bb1d126a199de0d6dafcbd5e122))
* **commands.cursor_moved:** ignore preview and floating windows ([#138](https://github.com/y3owk1n/undo-glow.nvim/issues/138)) ([5af6047](https://github.com/y3owk1n/undo-glow.nvim/commit/5af604726a696e4fa7f1f47d492bea4f3705df24))
* **utils.merge_command_opts:** make sure opts are always table ([#139](https://github.com/y3owk1n/undo-glow.nvim/issues/139)) ([79ba195](https://github.com/y3owk1n/undo-glow.nvim/commit/79ba1953c1dfc4de0460e99f3e5f6ce1e1ab4a69))

## [1.3.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.2.1...v1.3.0) (2025-02-25)


### Features

* add test for functions with CI ([#110](https://github.com/y3owk1n/undo-glow.nvim/issues/110)) ([e76839d](https://github.com/y3owk1n/undo-glow.nvim/commit/e76839daf46910be95dd9b84ba9755a9ed2385e9))
