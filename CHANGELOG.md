# Changelog

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
