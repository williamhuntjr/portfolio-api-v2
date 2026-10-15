'use strict';

// Projects created before `is_featured` / `is_discontinued` defaulted to false
// have them as NULL, which sorts separately from `false` and breaks the
// "featured first, active before discontinued, then A–Z" ordering.
// Normalise them to false.
module.exports = {
  async up(knex) {
    await knex('projects').whereNull('is_featured').update({ is_featured: false });
    await knex('projects').whereNull('is_discontinued').update({ is_discontinued: false });
  },
};
