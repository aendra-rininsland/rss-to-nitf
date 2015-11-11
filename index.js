var xslt = require('node_xslt')
var pd = require('pretty-data').pd;

var stylesheet = xslt.readXsltFile('./rss-to-nitf.xslt');
var doc = xslt.readXmlFile('./incoming.xml');
var transformedString = xslt.transform(stylesheet, doc, []);
console.log(pd.xml(transformedString));
