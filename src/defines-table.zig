const bun = @import("global.zig");
const string = bun.string;
const Output = bun.Output;
const Global = bun.Global;
const Environment = bun.Environment;
const strings = bun.strings;
const MutableString = bun.MutableString;
const stringZ = bun.stringZ;
const default_allocator = bun.default_allocator;
const C = bun.C;

// If something is in this list, then a direct identifier expression or property
// access chain matching this will be assumed to have no side effects and will
// be removed.
//
// This also means code is allowed to be reordered past things in this list. For
// example, if "console.log" is in this list, permitting reordering allows for
// "if (a) console.log(b); else console.log(c)" to be reordered and transformed
// into "console.log(a ? b : c)". Notice that "a" and "console.log" are in a
// different order, which can only happen if evaluating the "console.log"
// property access can be assumed to not change the value of "a".
//
// Note that membership in this list says nothing about whether calling any of
// these functions has any side effects. It only says something about
// referencing these function without calling them.
pub const GlobalDefinesKey = [_][]const string{
    // These global identifiers should exist in all JavaScript environments. This
    // deliberately omits "NaN", "Infinity", and "undefined" because these are
    // treated as automatically-inlined constants instead of identifiers.
    &[_]string{"Array"},
    &[_]string{"Boolean"},
    &[_]string{"Function"},
    &[_]string{"Math"},
    &[_]string{"Number"},
    &[_]string{"Object"},
    &[_]string{"RegExp"},
    &[_]string{"String"},

    // Object: Static methods
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object#Static_methods
    &[_]string{ "Object", "assign" },
    &[_]string{ "Object", "create" },
    &[_]string{ "Object", "defineProperties" },
    &[_]string{ "Object", "defineProperty" },
    &[_]string{ "Object", "entries" },
    &[_]string{ "Object", "freeze" },
    &[_]string{ "Object", "fromEntries" },
    &[_]string{ "Object", "getOwnPropertyDescriptor" },
    &[_]string{ "Object", "getOwnPropertyDescriptors" },
    &[_]string{ "Object", "getOwnPropertyNames" },
    &[_]string{ "Object", "getOwnPropertySymbols" },
    &[_]string{ "Object", "getPrototypeOf" },
    &[_]string{ "Object", "is" },
    &[_]string{ "Object", "isExtensible" },
    &[_]string{ "Object", "isFrozen" },
    &[_]string{ "Object", "isSealed" },
    &[_]string{ "Object", "keys" },
    &[_]string{ "Object", "preventExtensions" },
    &[_]string{ "Object", "seal" },
    &[_]string{ "Object", "setPrototypeOf" },
    &[_]string{ "Object", "values" },

    // Object: Instance methods
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Object#Instance_methods
    &[_]string{ "Object", "prototype", "__defineGetter__" },
    &[_]string{ "Object", "prototype", "__defineSetter__" },
    &[_]string{ "Object", "prototype", "__lookupGetter__" },
    &[_]string{ "Object", "prototype", "__lookupSetter__" },
    &[_]string{ "Object", "prototype", "hasOwnProperty" },
    &[_]string{ "Object", "prototype", "isPrototypeOf" },
    &[_]string{ "Object", "prototype", "propertyIsEnumerable" },
    &[_]string{ "Object", "prototype", "toLocaleString" },
    &[_]string{ "Object", "prototype", "toString" },
    &[_]string{ "Object", "prototype", "unwatch" },
    &[_]string{ "Object", "prototype", "valueOf" },
    &[_]string{ "Object", "prototype", "watch" },

    // Math: Static properties
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math#Static_properties
    &[_]string{ "Math", "E" },
    &[_]string{ "Math", "LN10" },
    &[_]string{ "Math", "LN2" },
    &[_]string{ "Math", "LOG10E" },
    &[_]string{ "Math", "LOG2E" },
    &[_]string{ "Math", "PI" },
    &[_]string{ "Math", "SQRT1_2" },
    &[_]string{ "Math", "SQRT2" },

    // Math: Static methods
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Math#Static_methods
    &[_]string{ "Math", "abs" },
    &[_]string{ "Math", "acos" },
    &[_]string{ "Math", "acosh" },
    &[_]string{ "Math", "asin" },
    &[_]string{ "Math", "asinh" },
    &[_]string{ "Math", "atan" },
    &[_]string{ "Math", "atan2" },
    &[_]string{ "Math", "atanh" },
    &[_]string{ "Math", "cbrt" },
    &[_]string{ "Math", "ceil" },
    &[_]string{ "Math", "clz32" },
    &[_]string{ "Math", "cos" },
    &[_]string{ "Math", "cosh" },
    &[_]string{ "Math", "exp" },
    &[_]string{ "Math", "expm1" },
    &[_]string{ "Math", "floor" },
    &[_]string{ "Math", "fround" },
    &[_]string{ "Math", "hypot" },
    &[_]string{ "Math", "imul" },
    &[_]string{ "Math", "log" },
    &[_]string{ "Math", "log10" },
    &[_]string{ "Math", "log1p" },
    &[_]string{ "Math", "log2" },
    &[_]string{ "Math", "max" },
    &[_]string{ "Math", "min" },
    &[_]string{ "Math", "pow" },
    &[_]string{ "Math", "random" },
    &[_]string{ "Math", "round" },
    &[_]string{ "Math", "sign" },
    &[_]string{ "Math", "sin" },
    &[_]string{ "Math", "sinh" },
    &[_]string{ "Math", "sqrt" },
    &[_]string{ "Math", "tan" },
    &[_]string{ "Math", "tanh" },
    &[_]string{ "Math", "trunc" },

    // Other globals present in both the browser and node (except "eval" because
    // it has special behavior)
    &[_]string{"AbortController"},
    &[_]string{"AbortSignal"},
    &[_]string{"AggregateError"},
    &[_]string{"ArrayBuffer"},
    &[_]string{"BigInt"},
    &[_]string{"DataView"},
    &[_]string{"Date"},
    &[_]string{"Error"},
    &[_]string{"EvalError"},
    &[_]string{"Event"},
    &[_]string{"EventTarget"},
    &[_]string{"Float32Array"},
    &[_]string{"Float64Array"},
    &[_]string{"Int16Array"},
    &[_]string{"Int32Array"},
    &[_]string{"Int8Array"},
    &[_]string{"Intl"},
    &[_]string{"JSON"},
    &[_]string{"Map"},
    &[_]string{"MessageChannel"},
    &[_]string{"MessageEvent"},
    &[_]string{"MessagePort"},
    &[_]string{"Promise"},
    &[_]string{"Proxy"},
    &[_]string{"RangeError"},
    &[_]string{"ReferenceError"},
    &[_]string{"Reflect"},
    &[_]string{"Set"},
    &[_]string{"Symbol"},
    &[_]string{"SyntaxError"},
    &[_]string{"TextDecoder"},
    &[_]string{"TextEncoder"},
    &[_]string{"TypeError"},
    &[_]string{"URIError"},
    &[_]string{"URL"},
    &[_]string{"URLSearchParams"},
    &[_]string{"Uint16Array"},
    &[_]string{"Uint32Array"},
    &[_]string{"Uint8Array"},
    &[_]string{"Uint8ClampedArray"},
    &[_]string{"WeakMap"},
    &[_]string{"WeakSet"},
    &[_]string{"WebAssembly"},
    &[_]string{"clearInterval"},
    &[_]string{"clearTimeout"},
    &[_]string{"console"},
    &[_]string{"decodeURI"},
    &[_]string{"decodeURIComponent"},
    &[_]string{"encodeURI"},
    &[_]string{"encodeURIComponent"},
    &[_]string{"escape"},
    &[_]string{"globalThis"},
    &[_]string{"isFinite"},
    &[_]string{"isNaN"},
    &[_]string{"parseFloat"},
    &[_]string{"parseInt"},
    &[_]string{"queueMicrotask"},
    &[_]string{"setInterval"},
    &[_]string{"setTimeout"},
    &[_]string{"unescape"},

    // Reflect: Static methods
    // https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Reflect#static_methods
    &[_]string{ "Reflect", "apply" },
    &[_]string{ "Reflect", "construct" },
    &[_]string{ "Reflect", "defineProperty" },
    &[_]string{ "Reflect", "deleteProperty" },
    &[_]string{ "Reflect", "get" },
    &[_]string{ "Reflect", "getOwnPropertyDescriptor" },
    &[_]string{ "Reflect", "getPrototypeOf" },
    &[_]string{ "Reflect", "has" },
    &[_]string{ "Reflect", "isExtensible" },
    &[_]string{ "Reflect", "ownKeys" },
    &[_]string{ "Reflect", "preventExtensions" },
    &[_]string{ "Reflect", "set" },
    &[_]string{ "Reflect", "setPrototypeOf" },

    // Console method references are assumed to have no side effects
    // https://developer.mozilla.org/en-US/docs/Web/API/console
    &[_]string{ "console", "assert" },
    &[_]string{ "console", "clear" },
    &[_]string{ "console", "count" },
    &[_]string{ "console", "countReset" },
    &[_]string{ "console", "debug" },
    &[_]string{ "console", "dir" },
    &[_]string{ "console", "dirxml" },
    &[_]string{ "console", "error" },
    &[_]string{ "console", "group" },
    &[_]string{ "console", "groupCollapsed" },
    &[_]string{ "console", "groupEnd" },
    &[_]string{ "console", "info" },
    &[_]string{ "console", "log" },
    &[_]string{ "console", "table" },
    &[_]string{ "console", "time" },
    &[_]string{ "console", "timeEnd" },
    &[_]string{ "console", "timeLog" },
    &[_]string{ "console", "trace" },
    &[_]string{ "console", "warn" },

    // CSSOM APIs
    &[_]string{"CSSAnimation"},
    &[_]string{"CSSFontFaceRule"},
    &[_]string{"CSSImportRule"},
    &[_]string{"CSSKeyframeRule"},
    &[_]string{"CSSKeyframesRule"},
    &[_]string{"CSSMediaRule"},
    &[_]string{"CSSNamespaceRule"},
    &[_]string{"CSSPageRule"},
    &[_]string{"CSSRule"},
    &[_]string{"CSSRuleList"},
    &[_]string{"CSSStyleDeclaration"},
    &[_]string{"CSSStyleRule"},
    &[_]string{"CSSStyleSheet"},
    &[_]string{"CSSSupportsRule"},
    &[_]string{"CSSTransition"},

    // SVG DOM
    &[_]string{"SVGAElement"},
    &[_]string{"SVGAngle"},
    &[_]string{"SVGAnimateElement"},
    &[_]string{"SVGAnimateMotionElement"},
    &[_]string{"SVGAnimateTransformElement"},
    &[_]string{"SVGAnimatedAngle"},
    &[_]string{"SVGAnimatedBoolean"},
    &[_]string{"SVGAnimatedEnumeration"},
    &[_]string{"SVGAnimatedInteger"},
    &[_]string{"SVGAnimatedLength"},
    &[_]string{"SVGAnimatedLengthList"},
    &[_]string{"SVGAnimatedNumber"},
    &[_]string{"SVGAnimatedNumberList"},
    &[_]string{"SVGAnimatedPreserveAspectRatio"},
    &[_]string{"SVGAnimatedRect"},
    &[_]string{"SVGAnimatedString"},
    &[_]string{"SVGAnimatedTransformList"},
    &[_]string{"SVGAnimationElement"},
    &[_]string{"SVGCircleElement"},
    &[_]string{"SVGClipPathElement"},
    &[_]string{"SVGComponentTransferFunctionElement"},
    &[_]string{"SVGDefsElement"},
    &[_]string{"SVGDescElement"},
    &[_]string{"SVGElement"},
    &[_]string{"SVGEllipseElement"},
    &[_]string{"SVGFEBlendElement"},
    &[_]string{"SVGFEColorMatrixElement"},
    &[_]string{"SVGFEComponentTransferElement"},
    &[_]string{"SVGFECompositeElement"},
    &[_]string{"SVGFEConvolveMatrixElement"},
    &[_]string{"SVGFEDiffuseLightingElement"},
    &[_]string{"SVGFEDisplacementMapElement"},
    &[_]string{"SVGFEDistantLightElement"},
    &[_]string{"SVGFEDropShadowElement"},
    &[_]string{"SVGFEFloodElement"},
    &[_]string{"SVGFEFuncAElement"},
    &[_]string{"SVGFEFuncBElement"},
    &[_]string{"SVGFEFuncGElement"},
    &[_]string{"SVGFEFuncRElement"},
    &[_]string{"SVGFEGaussianBlurElement"},
    &[_]string{"SVGFEImageElement"},
    &[_]string{"SVGFEMergeElement"},
    &[_]string{"SVGFEMergeNodeElement"},
    &[_]string{"SVGFEMorphologyElement"},
    &[_]string{"SVGFEOffsetElement"},
    &[_]string{"SVGFEPointLightElement"},
    &[_]string{"SVGFESpecularLightingElement"},
    &[_]string{"SVGFESpotLightElement"},
    &[_]string{"SVGFETileElement"},
    &[_]string{"SVGFETurbulenceElement"},
    &[_]string{"SVGFilterElement"},
    &[_]string{"SVGForeignObjectElement"},
    &[_]string{"SVGGElement"},
    &[_]string{"SVGGeometryElement"},
    &[_]string{"SVGGradientElement"},
    &[_]string{"SVGGraphicsElement"},
    &[_]string{"SVGImageElement"},
    &[_]string{"SVGLength"},
    &[_]string{"SVGLengthList"},
    &[_]string{"SVGLineElement"},
    &[_]string{"SVGLinearGradientElement"},
    &[_]string{"SVGMPathElement"},
    &[_]string{"SVGMarkerElement"},
    &[_]string{"SVGMaskElement"},
    &[_]string{"SVGMatrix"},
    &[_]string{"SVGMetadataElement"},
    &[_]string{"SVGNumber"},
    &[_]string{"SVGNumberList"},
    &[_]string{"SVGPathElement"},
    &[_]string{"SVGPatternElement"},
    &[_]string{"SVGPoint"},
    &[_]string{"SVGPointList"},
    &[_]string{"SVGPolygonElement"},
    &[_]string{"SVGPolylineElement"},
    &[_]string{"SVGPreserveAspectRatio"},
    &[_]string{"SVGRadialGradientElement"},
    &[_]string{"SVGRect"},
    &[_]string{"SVGRectElement"},
    &[_]string{"SVGSVGElement"},
    &[_]string{"SVGScriptElement"},
    &[_]string{"SVGSetElement"},
    &[_]string{"SVGStopElement"},
    &[_]string{"SVGStringList"},
    &[_]string{"SVGStyleElement"},
    &[_]string{"SVGSwitchElement"},
    &[_]string{"SVGSymbolElement"},
    &[_]string{"SVGTSpanElement"},
    &[_]string{"SVGTextContentElement"},
    &[_]string{"SVGTextElement"},
    &[_]string{"SVGTextPathElement"},
    &[_]string{"SVGTextPositioningElement"},
    &[_]string{"SVGTitleElement"},
    &[_]string{"SVGTransform"},
    &[_]string{"SVGTransformList"},
    &[_]string{"SVGUnitTypes"},
    &[_]string{"SVGUseElement"},
    &[_]string{"SVGViewElement"},

    // Other browser APIs
    //
    // This list contains all globals present in modern versions of Chrome, Safari,
    // and Firefox except for the following properties, since they have a side effect
    // of triggering layout (https://gist.github.com/paulirish/5d52fb081b3570c81e3a):
    //
    //   - scrollX
    //   - scrollY
    //   - innerWidth
    //   - innerHeight
    //   - pageXOffset
    //   - pageYOffset
    //
    // The following globals have also been removed since they sometimes throw an
    // exception when accessed, which is a side effect (for more information see
    // https://stackoverflow.com/a/33047477):
    //
    //   - localStorage
    //   - sessionStorage
    //
    &[_]string{"AnalyserNode"},
    &[_]string{"Animation"},
    &[_]string{"AnimationEffect"},
    &[_]string{"AnimationEvent"},
    &[_]string{"AnimationPlaybackEvent"},
    &[_]string{"AnimationTimeline"},
    &[_]string{"Attr"},
    &[_]string{"Audio"},
    &[_]string{"AudioBuffer"},
    &[_]string{"AudioBufferSourceNode"},
    &[_]string{"AudioDestinationNode"},
    &[_]string{"AudioListener"},
    &[_]string{"AudioNode"},
    &[_]string{"AudioParam"},
    &[_]string{"AudioProcessingEvent"},
    &[_]string{"AudioScheduledSourceNode"},
    &[_]string{"BarProp"},
    &[_]string{"BeforeUnloadEvent"},
    &[_]string{"BiquadFilterNode"},
    &[_]string{"Blob"},
    &[_]string{"BlobEvent"},
    &[_]string{"ByteLengthQueuingStrategy"},
    &[_]string{"CDATASection"},
    &[_]string{"CSS"},
    &[_]string{"CanvasGradient"},
    &[_]string{"CanvasPattern"},
    &[_]string{"CanvasRenderingContext2D"},
    &[_]string{"ChannelMergerNode"},
    &[_]string{"ChannelSplitterNode"},
    &[_]string{"CharacterData"},
    &[_]string{"ClipboardEvent"},
    &[_]string{"CloseEvent"},
    &[_]string{"Comment"},
    &[_]string{"CompositionEvent"},
    &[_]string{"ConvolverNode"},
    &[_]string{"CountQueuingStrategy"},
    &[_]string{"Crypto"},
    &[_]string{"CustomElementRegistry"},
    &[_]string{"CustomEvent"},
    &[_]string{"DOMException"},
    &[_]string{"DOMImplementation"},
    &[_]string{"DOMMatrix"},
    &[_]string{"DOMMatrixReadOnly"},
    &[_]string{"DOMParser"},
    &[_]string{"DOMPoint"},
    &[_]string{"DOMPointReadOnly"},
    &[_]string{"DOMQuad"},
    &[_]string{"DOMRect"},
    &[_]string{"DOMRectList"},
    &[_]string{"DOMRectReadOnly"},
    &[_]string{"DOMStringList"},
    &[_]string{"DOMStringMap"},
    &[_]string{"DOMTokenList"},
    &[_]string{"DataTransfer"},
    &[_]string{"DataTransferItem"},
    &[_]string{"DataTransferItemList"},
    &[_]string{"DelayNode"},
    &[_]string{"Document"},
    &[_]string{"DocumentFragment"},
    &[_]string{"DocumentTimeline"},
    &[_]string{"DocumentType"},
    &[_]string{"DragEvent"},
    &[_]string{"DynamicsCompressorNode"},
    &[_]string{"Element"},
    &[_]string{"ErrorEvent"},
    &[_]string{"EventSource"},
    &[_]string{"File"},
    &[_]string{"FileList"},
    &[_]string{"FileReader"},
    &[_]string{"FocusEvent"},
    &[_]string{"FontFace"},
    &[_]string{"FormData"},
    &[_]string{"GainNode"},
    &[_]string{"Gamepad"},
    &[_]string{"GamepadButton"},
    &[_]string{"GamepadEvent"},
    &[_]string{"Geolocation"},
    &[_]string{"GeolocationPositionError"},
    &[_]string{"HTMLAllCollection"},
    &[_]string{"HTMLAnchorElement"},
    &[_]string{"HTMLAreaElement"},
    &[_]string{"HTMLAudioElement"},
    &[_]string{"HTMLBRElement"},
    &[_]string{"HTMLBaseElement"},
    &[_]string{"HTMLBodyElement"},
    &[_]string{"HTMLButtonElement"},
    &[_]string{"HTMLCanvasElement"},
    &[_]string{"HTMLCollection"},
    &[_]string{"HTMLDListElement"},
    &[_]string{"HTMLDataElement"},
    &[_]string{"HTMLDataListElement"},
    &[_]string{"HTMLDetailsElement"},
    &[_]string{"HTMLDirectoryElement"},
    &[_]string{"HTMLDivElement"},
    &[_]string{"HTMLDocument"},
    &[_]string{"HTMLElement"},
    &[_]string{"HTMLEmbedElement"},
    &[_]string{"HTMLFieldSetElement"},
    &[_]string{"HTMLFontElement"},
    &[_]string{"HTMLFormControlsCollection"},
    &[_]string{"HTMLFormElement"},
    &[_]string{"HTMLFrameElement"},
    &[_]string{"HTMLFrameSetElement"},
    &[_]string{"HTMLHRElement"},
    &[_]string{"HTMLHeadElement"},
    &[_]string{"HTMLHeadingElement"},
    &[_]string{"HTMLHtmlElement"},
    &[_]string{"HTMLIFrameElement"},
    &[_]string{"HTMLImageElement"},
    &[_]string{"HTMLInputElement"},
    &[_]string{"HTMLLIElement"},
    &[_]string{"HTMLLabelElement"},
    &[_]string{"HTMLLegendElement"},
    &[_]string{"HTMLLinkElement"},
    &[_]string{"HTMLMapElement"},
    &[_]string{"HTMLMarqueeElement"},
    &[_]string{"HTMLMediaElement"},
    &[_]string{"HTMLMenuElement"},
    &[_]string{"HTMLMetaElement"},
    &[_]string{"HTMLMeterElement"},
    &[_]string{"HTMLModElement"},
    &[_]string{"HTMLOListElement"},
    &[_]string{"HTMLObjectElement"},
    &[_]string{"HTMLOptGroupElement"},
    &[_]string{"HTMLOptionElement"},
    &[_]string{"HTMLOptionsCollection"},
    &[_]string{"HTMLOutputElement"},
    &[_]string{"HTMLParagraphElement"},
    &[_]string{"HTMLParamElement"},
    &[_]string{"HTMLPictureElement"},
    &[_]string{"HTMLPreElement"},
    &[_]string{"HTMLProgressElement"},
    &[_]string{"HTMLQuoteElement"},
    &[_]string{"HTMLScriptElement"},
    &[_]string{"HTMLSelectElement"},
    &[_]string{"HTMLSlotElement"},
    &[_]string{"HTMLSourceElement"},
    &[_]string{"HTMLSpanElement"},
    &[_]string{"HTMLStyleElement"},
    &[_]string{"HTMLTableCaptionElement"},
    &[_]string{"HTMLTableCellElement"},
    &[_]string{"HTMLTableColElement"},
    &[_]string{"HTMLTableElement"},
    &[_]string{"HTMLTableRowElement"},
    &[_]string{"HTMLTableSectionElement"},
    &[_]string{"HTMLTemplateElement"},
    &[_]string{"HTMLTextAreaElement"},
    &[_]string{"HTMLTimeElement"},
    &[_]string{"HTMLTitleElement"},
    &[_]string{"HTMLTrackElement"},
    &[_]string{"HTMLUListElement"},
    &[_]string{"HTMLUnknownElement"},
    &[_]string{"HTMLVideoElement"},
    &[_]string{"HashChangeEvent"},
    &[_]string{"Headers"},
    &[_]string{"History"},
    &[_]string{"IDBCursor"},
    &[_]string{"IDBCursorWithValue"},
    &[_]string{"IDBDatabase"},
    &[_]string{"IDBFactory"},
    &[_]string{"IDBIndex"},
    &[_]string{"IDBKeyRange"},
    &[_]string{"IDBObjectStore"},
    &[_]string{"IDBOpenDBRequest"},
    &[_]string{"IDBRequest"},
    &[_]string{"IDBTransaction"},
    &[_]string{"IDBVersionChangeEvent"},
    &[_]string{"Image"},
    &[_]string{"ImageData"},
    &[_]string{"InputEvent"},
    &[_]string{"IntersectionObserver"},
    &[_]string{"IntersectionObserverEntry"},
    &[_]string{"KeyboardEvent"},
    &[_]string{"KeyframeEffect"},
    &[_]string{"Location"},
    &[_]string{"MediaCapabilities"},
    &[_]string{"MediaElementAudioSourceNode"},
    &[_]string{"MediaEncryptedEvent"},
    &[_]string{"MediaError"},
    &[_]string{"MediaList"},
    &[_]string{"MediaQueryList"},
    &[_]string{"MediaQueryListEvent"},
    &[_]string{"MediaRecorder"},
    &[_]string{"MediaSource"},
    &[_]string{"MediaStream"},
    &[_]string{"MediaStreamAudioDestinationNode"},
    &[_]string{"MediaStreamAudioSourceNode"},
    &[_]string{"MediaStreamTrack"},
    &[_]string{"MediaStreamTrackEvent"},
    &[_]string{"MimeType"},
    &[_]string{"MimeTypeArray"},
    &[_]string{"MouseEvent"},
    &[_]string{"MutationEvent"},
    &[_]string{"MutationObserver"},
    &[_]string{"MutationRecord"},
    &[_]string{"NamedNodeMap"},
    &[_]string{"Navigator"},
    &[_]string{"Node"},
    &[_]string{"NodeFilter"},
    &[_]string{"NodeIterator"},
    &[_]string{"NodeList"},
    &[_]string{"Notification"},
    &[_]string{"OfflineAudioCompletionEvent"},
    &[_]string{"Option"},
    &[_]string{"OscillatorNode"},
    &[_]string{"PageTransitionEvent"},
    &[_]string{"Path2D"},
    &[_]string{"Performance"},
    &[_]string{"PerformanceEntry"},
    &[_]string{"PerformanceMark"},
    &[_]string{"PerformanceMeasure"},
    &[_]string{"PerformanceNavigation"},
    &[_]string{"PerformanceObserver"},
    &[_]string{"PerformanceObserverEntryList"},
    &[_]string{"PerformanceResourceTiming"},
    &[_]string{"PerformanceTiming"},
    &[_]string{"PeriodicWave"},
    &[_]string{"Plugin"},
    &[_]string{"PluginArray"},
    &[_]string{"PointerEvent"},
    &[_]string{"PopStateEvent"},
    &[_]string{"ProcessingInstruction"},
    &[_]string{"ProgressEvent"},
    &[_]string{"PromiseRejectionEvent"},
    &[_]string{"RTCCertificate"},
    &[_]string{"RTCDTMFSender"},
    &[_]string{"RTCDTMFToneChangeEvent"},
    &[_]string{"RTCDataChannel"},
    &[_]string{"RTCDataChannelEvent"},
    &[_]string{"RTCIceCandidate"},
    &[_]string{"RTCPeerConnection"},
    &[_]string{"RTCPeerConnectionIceEvent"},
    &[_]string{"RTCRtpReceiver"},
    &[_]string{"RTCRtpSender"},
    &[_]string{"RTCRtpTransceiver"},
    &[_]string{"RTCSessionDescription"},
    &[_]string{"RTCStatsReport"},
    &[_]string{"RTCTrackEvent"},
    &[_]string{"RadioNodeList"},
    &[_]string{"Range"},
    &[_]string{"ReadableStream"},
    &[_]string{"Request"},
    &[_]string{"ResizeObserver"},
    &[_]string{"ResizeObserverEntry"},
    &[_]string{"Response"},
    &[_]string{"Screen"},
    &[_]string{"ScriptProcessorNode"},
    &[_]string{"SecurityPolicyViolationEvent"},
    &[_]string{"Selection"},
    &[_]string{"ShadowRoot"},
    &[_]string{"SourceBuffer"},
    &[_]string{"SourceBufferList"},
    &[_]string{"SpeechSynthesisEvent"},
    &[_]string{"SpeechSynthesisUtterance"},
    &[_]string{"StaticRange"},
    &[_]string{"Storage"},
    &[_]string{"StorageEvent"},
    &[_]string{"StyleSheet"},
    &[_]string{"StyleSheetList"},
    &[_]string{"Text"},
    &[_]string{"TextMetrics"},
    &[_]string{"TextTrack"},
    &[_]string{"TextTrackCue"},
    &[_]string{"TextTrackCueList"},
    &[_]string{"TextTrackList"},
    &[_]string{"TimeRanges"},
    &[_]string{"TrackEvent"},
    &[_]string{"TransitionEvent"},
    &[_]string{"TreeWalker"},
    &[_]string{"UIEvent"},
    &[_]string{"VTTCue"},
    &[_]string{"ValidityState"},
    &[_]string{"VisualViewport"},
    &[_]string{"WaveShaperNode"},
    &[_]string{"WebGLActiveInfo"},
    &[_]string{"WebGLBuffer"},
    &[_]string{"WebGLContextEvent"},
    &[_]string{"WebGLFramebuffer"},
    &[_]string{"WebGLProgram"},
    &[_]string{"WebGLQuery"},
    &[_]string{"WebGLRenderbuffer"},
    &[_]string{"WebGLRenderingContext"},
    &[_]string{"WebGLSampler"},
    &[_]string{"WebGLShader"},
    &[_]string{"WebGLShaderPrecisionFormat"},
    &[_]string{"WebGLSync"},
    &[_]string{"WebGLTexture"},
    &[_]string{"WebGLUniformLocation"},
    &[_]string{"WebKitCSSMatrix"},
    &[_]string{"WebSocket"},
    &[_]string{"WheelEvent"},
    &[_]string{"Window"},
    &[_]string{"Worker"},
    &[_]string{"XMLDocument"},
    &[_]string{"XMLHttpRequest"},
    &[_]string{"XMLHttpRequestEventTarget"},
    &[_]string{"XMLHttpRequestUpload"},
    &[_]string{"XMLSerializer"},
    &[_]string{"XPathEvaluator"},
    &[_]string{"XPathExpression"},
    &[_]string{"XPathResult"},
    &[_]string{"XSLTProcessor"},
    &[_]string{"alert"},
    &[_]string{"atob"},
    &[_]string{"blur"},
    &[_]string{"btoa"},
    &[_]string{"cancelAnimationFrame"},
    &[_]string{"captureEvents"},
    &[_]string{"close"},
    &[_]string{"closed"},
    &[_]string{"confirm"},
    &[_]string{"customElements"},
    &[_]string{"devicePixelRatio"},
    &[_]string{"document"},
    &[_]string{"event"},
    &[_]string{"fetch"},
    &[_]string{"find"},
    &[_]string{"focus"},
    &[_]string{"frameElement"},
    &[_]string{"frames"},
    &[_]string{"getComputedStyle"},
    &[_]string{"getSelection"},
    &[_]string{"history"},
    &[_]string{"indexedDB"},
    &[_]string{"isSecureContext"},
    &[_]string{"length"},
    &[_]string{"location"},
    &[_]string{"locationbar"},
    &[_]string{"matchMedia"},
    &[_]string{"menubar"},
    &[_]string{"moveBy"},
    &[_]string{"moveTo"},
    &[_]string{"name"},
    &[_]string{"navigator"},
    &[_]string{"onabort"},
    &[_]string{"onafterprint"},
    &[_]string{"onanimationend"},
    &[_]string{"onanimationiteration"},
    &[_]string{"onanimationstart"},
    &[_]string{"onbeforeprint"},
    &[_]string{"onbeforeunload"},
    &[_]string{"onblur"},
    &[_]string{"oncanplay"},
    &[_]string{"oncanplaythrough"},
    &[_]string{"onchange"},
    &[_]string{"onclick"},
    &[_]string{"oncontextmenu"},
    &[_]string{"oncuechange"},
    &[_]string{"ondblclick"},
    &[_]string{"ondrag"},
    &[_]string{"ondragend"},
    &[_]string{"ondragenter"},
    &[_]string{"ondragleave"},
    &[_]string{"ondragover"},
    &[_]string{"ondragstart"},
    &[_]string{"ondrop"},
    &[_]string{"ondurationchange"},
    &[_]string{"onemptied"},
    &[_]string{"onended"},
    &[_]string{"onerror"},
    &[_]string{"onfocus"},
    &[_]string{"ongotpointercapture"},
    &[_]string{"onhashchange"},
    &[_]string{"oninput"},
    &[_]string{"oninvalid"},
    &[_]string{"onkeydown"},
    &[_]string{"onkeypress"},
    &[_]string{"onkeyup"},
    &[_]string{"onlanguagechange"},
    &[_]string{"onload"},
    &[_]string{"onloadeddata"},
    &[_]string{"onloadedmetadata"},
    &[_]string{"onloadstart"},
    &[_]string{"onlostpointercapture"},
    &[_]string{"onmessage"},
    &[_]string{"onmousedown"},
    &[_]string{"onmouseenter"},
    &[_]string{"onmouseleave"},
    &[_]string{"onmousemove"},
    &[_]string{"onmouseout"},
    &[_]string{"onmouseover"},
    &[_]string{"onmouseup"},
    &[_]string{"onoffline"},
    &[_]string{"ononline"},
    &[_]string{"onpagehide"},
    &[_]string{"onpageshow"},
    &[_]string{"onpause"},
    &[_]string{"onplay"},
    &[_]string{"onplaying"},
    &[_]string{"onpointercancel"},
    &[_]string{"onpointerdown"},
    &[_]string{"onpointerenter"},
    &[_]string{"onpointerleave"},
    &[_]string{"onpointermove"},
    &[_]string{"onpointerout"},
    &[_]string{"onpointerover"},
    &[_]string{"onpointerup"},
    &[_]string{"onpopstate"},
    &[_]string{"onprogress"},
    &[_]string{"onratechange"},
    &[_]string{"onrejectionhandled"},
    &[_]string{"onreset"},
    &[_]string{"onresize"},
    &[_]string{"onscroll"},
    &[_]string{"onseeked"},
    &[_]string{"onseeking"},
    &[_]string{"onselect"},
    &[_]string{"onstalled"},
    &[_]string{"onstorage"},
    &[_]string{"onsubmit"},
    &[_]string{"onsuspend"},
    &[_]string{"ontimeupdate"},
    &[_]string{"ontoggle"},
    &[_]string{"ontransitioncancel"},
    &[_]string{"ontransitionend"},
    &[_]string{"ontransitionrun"},
    &[_]string{"ontransitionstart"},
    &[_]string{"onunhandledrejection"},
    &[_]string{"onunload"},
    &[_]string{"onvolumechange"},
    &[_]string{"onwaiting"},
    &[_]string{"onwebkitanimationend"},
    &[_]string{"onwebkitanimationiteration"},
    &[_]string{"onwebkitanimationstart"},
    &[_]string{"onwebkittransitionend"},
    &[_]string{"onwheel"},
    &[_]string{"open"},
    &[_]string{"opener"},
    &[_]string{"origin"},
    &[_]string{"outerHeight"},
    &[_]string{"outerWidth"},
    &[_]string{"parent"},
    &[_]string{"performance"},
    &[_]string{"personalbar"},
    &[_]string{"postMessage"},
    &[_]string{"print"},
    &[_]string{"prompt"},
    &[_]string{"releaseEvents"},
    &[_]string{"requestAnimationFrame"},
    &[_]string{"resizeBy"},
    &[_]string{"resizeTo"},
    &[_]string{"screen"},
    &[_]string{"screenLeft"},
    &[_]string{"screenTop"},
    &[_]string{"screenX"},
    &[_]string{"screenY"},
    &[_]string{"scroll"},
    &[_]string{"scrollBy"},
    &[_]string{"scrollTo"},
    &[_]string{"scrollbars"},
    &[_]string{"self"},
    &[_]string{"speechSynthesis"},
    &[_]string{"status"},
    &[_]string{"statusbar"},
    &[_]string{"stop"},
    &[_]string{"toolbar"},
    &[_]string{"top"},
    &[_]string{"webkitURL"},
    &[_]string{"window"},
};
