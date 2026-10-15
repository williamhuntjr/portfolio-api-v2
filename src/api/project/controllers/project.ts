/**
 *  project controller
 */

import { factories } from '@strapi/strapi';

export default factories.createCoreController('api::project.project', () => ({
  async find(ctx) {
    // Default ordering: the featured project first, active projects before
    // discontinued ones, then A–Z by name.
    // A `sort` passed by the client still takes precedence.
    if (!ctx.query.sort) {
      ctx.query = { ...ctx.query, sort: ['is_featured:desc', 'is_discontinued:asc', 'name:asc'] };
    }

    return super.find(ctx);
  },
}));
