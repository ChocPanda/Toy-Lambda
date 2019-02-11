module.exports = {
  "extends": ["prettier", "airbnb-base", "plugin:prettier/recommended"],
  "plugins": ["prettier"],
  "rules": {
    "import/no-extraneous-dependencies":"off",
    "prettier/prettier": ["error"]
  },
  "overrides": [
      {
        "files": "*.test.js",
        "rules": {
          "func-names": 0,
          "prefer-arrow-callback": 0
        }
      }
  ]
};
