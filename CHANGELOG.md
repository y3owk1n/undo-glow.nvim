# Changelog

## [1.11.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.7...v1.11.0) (2025-09-21)


### Features

* **integrations:** add `flash.nvim` integration ([#268](https://github.com/y3owk1n/undo-glow.nvim/issues/268)) ([00532e9](https://github.com/y3owk1n/undo-glow.nvim/commit/00532e94f448b15ce255c80e64c61555b577e543))
* **integrations:** add `substitute.nvim` integration ([#267](https://github.com/y3owk1n/undo-glow.nvim/issues/267)) ([da5a162](https://github.com/y3owk1n/undo-glow.nvim/commit/da5a162456fdcc7dde0f3d1cfb0469af1ebd0a14))
* **integrations:** add `yanky.nvim` integration ([#264](https://github.com/y3owk1n/undo-glow.nvim/issues/264)) ([074aed1](https://github.com/y3owk1n/undo-glow.nvim/commit/074aed154ca3f850f1a37f698db56b9fa1c2a97f))


### Bug Fixes

* **integrations:** guard integrations with pcall to package ([#269](https://github.com/y3owk1n/undo-glow.nvim/issues/269)) ([a001ccc](https://github.com/y3owk1n/undo-glow.nvim/commit/a001ccc57bc07f5ab7ee9a400d57dd92a97b6695))

## [1.10.7](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.6...v1.10.7) (2025-09-09)


### Bug Fixes

* add `fallback_for_transparency` to support actual transparent background themes ([#259](https://github.com/y3owk1n/undo-glow.nvim/issues/259)) ([5d1bf88](https://github.com/y3owk1n/undo-glow.nvim/commit/5d1bf88c9da54be462e1dc17d8bb449ecd3282a8))

## [1.10.6](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.5...v1.10.6) (2025-08-17)


### Bug Fixes

* ensure line are actually string instead of blob before pass to `vim.fn.strdisplay` (fixes [#255](https://github.com/y3owk1n/undo-glow.nvim/issues/255)) ([#256](https://github.com/y3owk1n/undo-glow.nvim/issues/256)) ([290bd9d](https://github.com/y3owk1n/undo-glow.nvim/commit/290bd9d639b5a724248e6766f39af8cba3b567cc))

## [1.10.5](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.4...v1.10.5) (2025-08-10)


### Bug Fixes

* **ci:** split out docs generation from CI for better collaborations ([#253](https://github.com/y3owk1n/undo-glow.nvim/issues/253)) ([03a9624](https://github.com/y3owk1n/undo-glow.nvim/commit/03a96242e95ec7df24b97169aa04720c190cb83b))

## [1.10.4](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.3...v1.10.4) (2025-07-20)


### Bug Fixes

* **docs:** switch doc gen from `pandocvim` to `vimcats` ([#249](https://github.com/y3owk1n/undo-glow.nvim/issues/249)) ([2bc5a41](https://github.com/y3owk1n/undo-glow.nvim/commit/2bc5a41dd5243006d755df2265275742d0763470))
* remove whitespace ([#250](https://github.com/y3owk1n/undo-glow.nvim/issues/250)) ([62ae373](https://github.com/y3owk1n/undo-glow.nvim/commit/62ae37311fd71a2d5da32b1b30ca9882d7c7b86a))
* **utils:** escape search pattern to prevent "unfinished capture" error ([#247](https://github.com/y3owk1n/undo-glow.nvim/issues/247)) ([2c2ee58](https://github.com/y3owk1n/undo-glow.nvim/commit/2c2ee5819107eac8662ed693008fe47f91c3f8b1))

## [1.10.3](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.2...v1.10.3) (2025-06-03)


### Bug Fixes

* **commands.paste:** add support for count (fixes [#243](https://github.com/y3owk1n/undo-glow.nvim/issues/243)) ([#244](https://github.com/y3owk1n/undo-glow.nvim/issues/244)) ([3051c0b](https://github.com/y3owk1n/undo-glow.nvim/commit/3051c0bde5efbc598ac8125c1d5d38b0990a231d))

## [1.10.2](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.1...v1.10.2) (2025-04-16)


### Bug Fixes

* **utils:** add `get_current_cursor_row` utils for integrations ([#239](https://github.com/y3owk1n/undo-glow.nvim/issues/239)) ([8458574](https://github.com/y3owk1n/undo-glow.nvim/commit/8458574b2029418dedf2214481598761d68c6341))
* **utils:** add `get_current_cursor_word` utils for integration purpose ([#237](https://github.com/y3owk1n/undo-glow.nvim/issues/237)) ([55205e3](https://github.com/y3owk1n/undo-glow.nvim/commit/55205e319813bb11df19462474e299c08c9ed7c6))

## [1.10.1](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.10.0...v1.10.1) (2025-04-13)


### Bug Fixes

* **health:** config no longer exported from init.lua ([#235](https://github.com/y3owk1n/undo-glow.nvim/issues/235)) ([3c8029c](https://github.com/y3owk1n/undo-glow.nvim/commit/3c8029c2148f9f64da4660ec687502ac80ea3534))

## [1.10.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.9.0...v1.10.0) (2025-04-10)


### Features

* **commands.cursor_moved:** allow configuring `steps_to_trigger` for `cursor_moved` command ([#232](https://github.com/y3owk1n/undo-glow.nvim/issues/232)) ([ca3345c](https://github.com/y3owk1n/undo-glow.nvim/commit/ca3345cf44eb902bb27fa2081cb8f3d85fa5c671))

## [1.9.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.8.0...v1.9.0) (2025-03-19)


### Features

* **commands:** add search hash command ([#227](https://github.com/y3owk1n/undo-glow.nvim/issues/227)) ([0414890](https://github.com/y3owk1n/undo-glow.nvim/commit/041489034b082b133192726c39b7e879e0031d7d))


### Bug Fixes

* **animation.slide:** `ns_id` is invalid when switching buffer very quickly ([#229](https://github.com/y3owk1n/undo-glow.nvim/issues/229)) ([03d400d](https://github.com/y3owk1n/undo-glow.nvim/commit/03d400d6282c1baff639eeff22c8beca5a4291c2))

## [1.8.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.7.1...v1.8.0) (2025-03-08)


### Features

* **animation:** add end_animation function to animate_fn to end the animation easier ([#219](https://github.com/y3owk1n/undo-glow.nvim/issues/219)) ([aead0ac](https://github.com/y3owk1n/undo-glow.nvim/commit/aead0ac612d750df1fe568a4dea9390b3c6059f5))


### Bug Fixes

* **animation.slide:** add pcall for setting extmark ([#215](https://github.com/y3owk1n/undo-glow.nvim/issues/215)) ([48e71fd](https://github.com/y3owk1n/undo-glow.nvim/commit/48e71fdac04645771d0e89ca681ae45c04fd4511))
* **animation.slide:** fixes end_col out of range error in certain cases ([#217](https://github.com/y3owk1n/undo-glow.nvim/issues/217)) ([a74cd7a](https://github.com/y3owk1n/undo-glow.nvim/commit/a74cd7ab1a47d2365b8edfdb74ed35f6ff125338))
* **commands:** ignore cursor_moved for paste commands ([#213](https://github.com/y3owk1n/undo-glow.nvim/issues/213)) ([1a5dc1a](https://github.com/y3owk1n/undo-glow.nvim/commit/1a5dc1ae1ad98d6a3d6395cb405b03794797c47c))
* **cursor_moved:** only run in normal mode ([#220](https://github.com/y3owk1n/undo-glow.nvim/issues/220)) ([2b3e2ac](https://github.com/y3owk1n/undo-glow.nvim/commit/2b3e2ac322621578dce8eb868bb288872915d26b))
* ensure standardization of error namespace ([#216](https://github.com/y3owk1n/undo-glow.nvim/issues/216)) ([2189c15](https://github.com/y3owk1n/undo-glow.nvim/commit/2189c158cea6ce547b02f455b2ba30ce3f70a5ea))
* remove Snacks.debug... sorry! ([#218](https://github.com/y3owk1n/undo-glow.nvim/issues/218)) ([18fd386](https://github.com/y3owk1n/undo-glow.nvim/commit/18fd386b79bf5960aed34b83b3c9887baa4a4e8e))

## [1.7.1](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.7.0...v1.7.1) (2025-03-06)


### Bug Fixes

* **utils.create_extmark_opts:** different API for setting windown namespace for nightly and stable ([#210](https://github.com/y3owk1n/undo-glow.nvim/issues/210)) ([c521dd8](https://github.com/y3owk1n/undo-glow.nvim/commit/c521dd801b56cfc0a14f4fc8c636f987e7bebfb7))

## [1.7.0](https://github.com/y3owk1n/undo-glow.nvim/compare/v1.6.0...v1.7.0) (2025-03-05)


### Features

* add ability to scope highlights to current window only ([#205](https://github.com/y3owk1n/undo-glow.nvim/issues/205)) ([14725d1](https://github.com/y3owk1n/undo-glow.nvim/commit/14725d117e83ca63f1882015633dd82ce78f1462))
* add multiline support for `slide` animation ([#202](https://github.com/y3owk1n/undo-glow.nvim/issues/202)) ([5be5e93](https://github.com/y3owk1n/undo-glow.nvim/commit/5be5e93747be1b7e43f76e5a187ee3575b61dce2))
* **animation.slide:** rework animation for slide & remove reverse variant ([#197](https://github.com/y3owk1n/undo-glow.nvim/issues/197)) ([1278268](https://github.com/y3owk1n/undo-glow.nvim/commit/12782683d7600c0fd5abb07d731eaeeaf64ad285))
* **commands:** add new command to highlight current line after a search is performad from cmdline "/" or "?" ([#195](https://github.com/y3owk1n/undo-glow.nvim/issues/195)) ([6e6e924](https://github.com/y3owk1n/undo-glow.nvim/commit/6e6e924da1b6a38b082d931583499dd6d7dd6893))
* make extmark_id into a table for better flexibility ([#201](https://github.com/y3owk1n/undo-glow.nvim/issues/201)) ([64c9e05](https://github.com/y3owk1n/undo-glow.nvim/commit/64c9e05fe0dffe12f3f1987144288c656ecb8948))


### Bug Fixes

* **animation.jitter:** bump rgb random range to 30 ([#182](https://github.com/y3owk1n/undo-glow.nvim/issues/182)) ([213dc4a](https://github.com/y3owk1n/undo-glow.nvim/commit/213dc4abe12e2335095ab493a80acf406865a196))
* **commands:** ignore cursor moved for undo and redo command ([#193](https://github.com/y3owk1n/undo-glow.nvim/issues/193)) ([ec64f1a](https://github.com/y3owk1n/undo-glow.nvim/commit/ec64f1a712ed26d34dc8be3842b68e75e4912fe1))
* **commands:** ignore cursor_moved for yank and comment ([#200](https://github.com/y3owk1n/undo-glow.nvim/issues/200)) ([41010d3](https://github.com/y3owk1n/undo-glow.nvim/commit/41010d31181d75123c87916a25e4796e0e7c20f8))
* remove unneccessary caching ([#192](https://github.com/y3owk1n/undo-glow.nvim/issues/192)) ([3b151a2](https://github.com/y3owk1n/undo-glow.nvim/commit/3b151a2675b1fd93787372ec5d9cbca7d07ef6a2))
* **types:** make ns optional for handle_highlight function ([#206](https://github.com/y3owk1n/undo-glow.nvim/issues/206)) ([6fe8778](https://github.com/y3owk1n/undo-glow.nvim/commit/6fe877837649bf435346ad03657d6a43f2e4c006))
* **utils.animate_or_clear_highlights:** handle error if animation_type is not valid and fallback to fade ([#198](https://github.com/y3owk1n/undo-glow.nvim/issues/198)) ([3b98ffd](https://github.com/y3owk1n/undo-glow.nvim/commit/3b98ffdfd7cfc2cf3ead8852e68ca9fd6d5e93da))
* **utils.create_namespace:** sync available win namespaces to avoid overheads ([#209](https://github.com/y3owk1n/undo-glow.nvim/issues/209)) ([70f0fb5](https://github.com/y3owk1n/undo-glow.nvim/commit/70f0fb5b9ab30378147b2d401855472922d0ca29))
* **utils.get_search_star_region:** start search from cursor column to return next match ([#187](https://github.com/y3owk1n/undo-glow.nvim/issues/187)) ([b7d8a29](https://github.com/y3owk1n/undo-glow.nvim/commit/b7d8a29a65c44afe0c110f18756180e55f3fda1b))
* **utils.handle_highlight:** do not import utils and use it from the module itself ([#208](https://github.com/y3owk1n/undo-glow.nvim/issues/208)) ([c5e1e87](https://github.com/y3owk1n/undo-glow.nvim/commit/c5e1e873da377bb6a7ef949839e2526d8f095a48))
* **utils.search:** parse lines and patterns in lowercase ([#185](https://github.com/y3owk1n/undo-glow.nvim/issues/185)) ([5058690](https://github.com/y3owk1n/undo-glow.nvim/commit/50586905a6a0f0482c6d761de5cc30a7b49fc3d8))


### Performance Improvements

* **color:** slight refactor and add caching ([#190](https://github.com/y3owk1n/undo-glow.nvim/issues/190)) ([3d6a2c7](https://github.com/y3owk1n/undo-glow.nvim/commit/3d6a2c7e9089126608e04ddacc5e7cbeb74bfd27))
* **highlight:** slight refactor and add caching ([#189](https://github.com/y3owk1n/undo-glow.nvim/issues/189)) ([a794531](https://github.com/y3owk1n/undo-glow.nvim/commit/a794531e1270125edb61462e8aec7717b74b8ff4))
* **utils:** slight refactor and add caching ([#188](https://github.com/y3owk1n/undo-glow.nvim/issues/188)) ([86373cd](https://github.com/y3owk1n/undo-glow.nvim/commit/86373cdff658ebce64c2a136ec737418451cd4ed))

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
