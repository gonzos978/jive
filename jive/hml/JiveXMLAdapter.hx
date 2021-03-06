package jive.hml;

#if macro
import jive.hml.JiveXMLElementParser;
import hml.xml.reader.DefaultXMLDocumentParser;
import hml.xml.reader.IXMLParser.IXMLNodeParser;
import hml.xml.typeResolver.IHaxeTypeResolver;
import hml.xml.writer.IHaxeWriter.IHaxeNodeWriter;
import hml.xml.typeResolver.IHaxeTypeResolver.IXMLDataNodeParser;
import hml.xml.typeResolver.DefaultXMLDataRootParser;
import hml.xml.adapters.DefaultXMLAdapter;
import hml.xml.Data;

class JiveXMLAdapter extends DefaultXMLAdapter {
    public function new() { super(); }

    public override function getXmlNodeParsers():Array<IXMLNodeParser<XMLData>> {
        return [new JiveXMLElementParser(), new DefaultXMLDocumentParser()];
    }

    public override function getXmlDataNodeParsers():Array<IXMLDataNodeParser<XMLData, Node, Node>> {
        return [new JiveXMLDataParser(), new DefaultXMLDataRootParser()];
    }

    public override function getNodeWriters():Array<IHaxeNodeWriter<Node>> {
        return super.getNodeWriters().concat([
            new JiveIntWriter(),
            new JiveFloatWriter(),
            new JiveBoolWriter(),
            new JiveStringWriter(),
            new JiveListWriter(),
            new JiveStringMapWriter()
        ]);
    }

    public override function getTypeResolvers():Array<IHaxeTypeResolver<Node, Type>> {
        return super.getTypeResolvers().concat([new JiveTypeResolver()]);
    }
}
#end