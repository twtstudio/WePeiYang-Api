config = module.exports = {}

config.schoolStart = '2015-03-09'
config.week = parseInt((Date.now() - (new Date(config.schoolStart)).valueOf()) / (1000 * 60 * 60 * 24 * 7)) + 1