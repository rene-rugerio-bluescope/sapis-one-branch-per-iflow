package script

import com.sap.gateway.ip.core.customdev.util.Message
import com.sap.it.api.mapping.ValueMappingApi

def Message processData(Message message, ValueMappingApi api) {
    def sourceVal = message.getProperty("sourceFolder")
    def mapped = api.getMappedValue("SourceSFTPFolder", "IncomingSFTP", sourceVal,
                                     "DestinationMessageQueue", "OutgoingQueue")
    message.setProperty("destinationFolder", mapped ?: "UNKNOWN_EXCHANGE")
    return message
}