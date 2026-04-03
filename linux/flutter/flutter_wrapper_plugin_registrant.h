//
//  Flutter wrapper plugin registrant header
//

#ifndef FLUTTER_WRAPPER_PLUGIN_REGISTRANT_H_
#define FLUTTER_WRAPPER_PLUGIN_REGISTRANT_H_

// Forward declaration
struct FlPluginRegistry;
typedef struct FlPluginRegistry FlPluginRegistry;

void fl_register_plugins(FlPluginRegistry* registry);

#endif  // FLUTTER_WRAPPER_PLUGIN_REGISTRANT_H_
