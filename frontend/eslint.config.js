import js from '@eslint/js'
import pluginVue from 'eslint-plugin-vue'
import * as parserVue from 'vue-eslint-parser'
import * as parserTypeScript from '@typescript-eslint/parser'

export default [
    {
        name: 'app/files-to-lint',
        files: ['**/*.{ts,mts,tsx,vue}'],
    },

    {
        name: 'app/files-to-ignore',
        ignores: ['**/dist/**', '**/dist-ssr/**', '**/coverage/**'],
    },

    js.configs.recommended,
    ...pluginVue.configs['flat/essential'],

    {
        name: 'app/vue-rules',
        files: ['**/*.vue'],
        languageOptions: {
            parser: parserVue,
            parserOptions: {
                ecmaVersion: 'latest',
                extraFileExtensions: ['.vue'],
                parser: parserTypeScript,
                sourceType: 'module',
            },
        },
        rules: {
            'vue/multi-word-component-names': 'off',
        },
    },

    {
        name: 'app/ts-rules',
        files: ['**/*.{ts,mts,tsx}'],
        languageOptions: {
            parser: parserTypeScript,
            parserOptions: {
                ecmaVersion: 'latest',
                sourceType: 'module',
            },
        },
        rules: {
            '@typescript-eslint/no-explicit-any': 'off',
            '@typescript-eslint/no-unused-vars': ['warn', { argsIgnorePattern: '^_' }],
        },
    },
]
