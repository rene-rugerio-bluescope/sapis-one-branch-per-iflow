// This is Groovy Flowstep Version 2.x, running with Groovy runtime 4, Downgrade the script if older behaviour needed.

package script.v2

import com.sap.it.script.v2.api.Message
import com.sap.it.api.ITApiFactory
import com.sap.it.api.mapping.ValueMappingApi

def Message processData(Message message) {
    def sourceVal = message.getProperty("sourceFolder")

    def api = ITApiFactory.getApi(ValueMappingApi.class, null)
    if (api == null) {
        throw new Exception("Could not retrieve ValueMappingAPI.")
    }

    def mapped = api.getMappedValue("SourceSFTPFolder", "IncomingSFTP", sourceVal,
                                     "DestinationMessageQueue", "OutgoingQueue")

    message.setProperty("destinationFolder", mapped ?: "UNKNOWN_EXCHANGE")

    return message
}