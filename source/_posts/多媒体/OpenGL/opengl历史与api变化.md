---
layout: post
title: OpenGL历史与API变化
date: '2020-03-06 09:52'
tags:
  - opengl
categories:
  - 多媒体
  - OpenGL
abbrlink: 32043
---

OpenGL API在不同的版本中的扩展。

<!--more-->

## OpenGL 4.6 (2017)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| The [SPIR-V](https://www.khronos.org/opengl/wiki/SPIR-V) language can be used to define shaders. | [ARB_gl_spirv](http://www.opengl.org/registry/specs/ARB/gl_spirv.txt), [ARB_spirv_extensions](http://www.opengl.org/registry/specs/ARB/spirv_extensions.txt) |
| [Vertex shaders](https://www.khronos.org/opengl/wiki/Vertex_Shader#Other_inputs) can get the draw ID and base vertex/instance values from rendering commands. | [ARB_shader_draw_parameters](http://www.opengl.org/registry/specs/ARB/shader_draw_parameters.txt) |
| Multi-draw indirect rendering commands that can fetch the number of draws from a buffer. | [ARB_indirect_parameters](http://www.opengl.org/registry/specs/ARB/indirect_parameters.txt) |
| Statistics and transform feedback overflow queries.          | [ARB_pipeline_statistics_query](http://www.opengl.org/registry/specs/ARB/pipeline_statistics_query.txt), [ARB_transform_feedback_overflow_query](http://www.opengl.org/registry/specs/ARB/transform_feedback_overflow_query.txt) |
| [Anisotropic Filtering](https://www.khronos.org/opengl/wiki/Anisotropic_Filtering) | [ARB_texture_filter_anisotropic](http://www.opengl.org/registry/specs/ARB/texture_filter_anisotropic.txt) |
| Clamping polygon offsets                                     | [ARB_polygon_offset_clamp](http://www.opengl.org/registry/specs/ARB/polygon_offset_clamp.txt) |
| [OpenGL Contexts](https://www.khronos.org/opengl/wiki/OpenGL_Context) can be created that [do not report errors](https://www.khronos.org/opengl/wiki/OpenGL_Error#No_error_contexts) of any kind. | [KHR_no_error](http://www.opengl.org/registry/specs/KHR/no_error.txt) |
| More operations for [Atomic Counters](https://www.khronos.org/opengl/wiki/Atomic_Counter). | [ARB_shader_atomic_counter_ops](http://www.opengl.org/registry/specs/ARB/shader_atomic_counter_ops.txt) |
| Avoiding divergent shader invocations, where they are unnecessary. | [ARB_shader_group_vote](http://www.opengl.org/registry/specs/ARB/shader_group_vote.txt) |

Links:

- [OpenGL 4.6 Core Profile Specification](https://khronos.org/registry/OpenGL/specs/gl/glspec46.core.pdf)
- [OpenGL 4.6 Compatibility Profile Specification](https://khronos.org/registry/OpenGL/specs/gl/glspec46.compatibility.pdf)
- [OpenGL Shading Language 4.60 Specification](https://khronos.org/registry/OpenGL/specs/gl/GLSLangSpec.4.60.pdf)

## OpenGL 4.5 (2014)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Additional clip control modes to configure how clip space is mapped to window space. | [ARB_clip_control](http://www.opengl.org/registry/specs/ARB/clip_control.txt) |
| Adds a new GLSL gl_CullDistance shader output, similar to gl_ClipDistance, but used for whole primitive culling. | [ARB_cull_distance](http://www.opengl.org/registry/specs/ARB/cull_distance.txt) |
| Compatibility with OpenGL ES 3.1                             | [ARB_ES3_1_compatibility](http://www.opengl.org/registry/specs/ARB/ES3_1_compatibility.txt) |
| Adds new modes to [glBeginConditionalRender](https://www.khronos.org/opengl/wiki/GLAPI/glBeginConditionalRender) which invert condition used to determine whether to draw or not. | [ARB_conditional_render_inverted](http://www.opengl.org/registry/specs/ARB/conditional_render_inverted.txt) |
| Provides control over the spacial granularity at which the underlying implementation computes derivatives. | [ARB_derivative_control](http://www.opengl.org/registry/specs/ARB/derivative_control.txt) |
| Allows [modifying and querying object state without binding objects](https://www.khronos.org/opengl/wiki/Direct_State_Access). | [ARB_direct_state_access](http://www.opengl.org/registry/specs/ARB/direct_state_access.txt) |
| Adds a new function to get sub-regions of texture images.    | [ARB_get_texture_sub_image](http://www.opengl.org/registry/specs/ARB/get_texture_sub_image.txt) |
| Upgrades the [ARB_robustness](http://www.opengl.org/registry/specs/ARB/robustness.txt) functionality to meet ES 3.1 standards. | [KHR_robustness](http://www.opengl.org/registry/specs/KHR/robustness.txt) |
| Provides GLSL built-in functions allowing shaders to query the number of samples of a texture. | [ARB_shader_texture_image_samples](http://www.opengl.org/registry/specs/ARB/shader_texture_image_samples.txt) |
| Relaxes the restrictions on rendering to a currently bound texture and [provides a mechanism to avoid read-after-write hazards](https://www.khronos.org/opengl/wiki/Texture_Barrier). | [ARB_texture_barrier](http://www.opengl.org/registry/specs/ARB/texture_barrier.txt) |

Links:

- [OpenGL 4.5 Core Profile Specification](http://www.opengl.org/registry/doc/glspec45.core.pdf)
- [OpenGL 4.5 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec45.compatibility.pdf)
- [OpenGL Shading Language 4.50 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.50.pdf)

## OpenGL 4.4 (2013)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Immutable storage for buffer objects,](https://www.khronos.org/opengl/wiki/Immutable_Buffer_Storage) including the ability to use buffers while they are mapped. | [ARB_buffer_storage](http://www.opengl.org/registry/specs/ARB/buffer_storage.txt) |
| [Direct clearing of a texture image.](https://www.khronos.org/opengl/wiki/Clear_Texture) | [ARB_clear_texture](http://www.opengl.org/registry/specs/ARB/clear_texture.txt) |
| [A number of enhancements to layout qualifiers:](https://www.khronos.org/opengl/wiki/Layout_Qualifier_(GLSL)) Integer layout qualifiers can take any [constant expression](https://www.khronos.org/opengl/wiki/Constant_Expression), not just integer literals. [Explicit layout requests for buffer-backed interface blocks.](https://www.khronos.org/opengl/wiki/Buffer_Backed_Interface_Block) [Tight packing of disparate input/output variables](https://www.khronos.org/opengl/wiki/Layout_Component). [In-shader specification of transform feedback parameters.](https://www.khronos.org/opengl/wiki/Feedback_In_Shader_Binding) [Locations can be set on input/output interface blocks](https://www.khronos.org/opengl/wiki/Layout_Block_Member_Location), for packing purposes. | [ARB_enhanced_layouts](http://www.opengl.org/registry/specs/ARB/enhanced_layouts.txt) |
| Bind an [array of objects of the same type to a sequential range of indexed binding targets](https://www.khronos.org/opengl/wiki/Multibind) in one call. | [ARB_multi_bind](http://www.opengl.org/registry/specs/ARB/multi_bind.txt) |
| Values from Query Objects values can be written to a [buffer object instead of directly to client memory.](https://www.khronos.org/opengl/wiki/Query_Buffer_Object) | [ARB_query_buffer_object](http://www.opengl.org/registry/specs/ARB/query_buffer_object.txt) |
| A [special clamping mode](https://www.khronos.org/opengl/wiki/Edge_Sampling) that doubles the size of the texture in each dimension, mirroring it exactly once in the negative texture coordinate directions. | [ARB_texture_mirror_clamp_to_edge](http://www.opengl.org/registry/specs/ARB/texture_mirror_clamp_to_edge.txt) |
| One of the [stencil-only image formats](https://www.khronos.org/opengl/wiki/Stencil_Image_Format) can be used for textures, and 8-bit stencil is a [required format](https://www.khronos.org/opengl/wiki/Required_Image_Format). | [ARB_texture_stencil8](http://www.opengl.org/registry/specs/ARB/texture_stencil8.txt) |
| Provides a packed, 3-component 11F/11F/10F format for [vertex attributes](https://www.khronos.org/opengl/wiki/Vertex_Format_Type). | [ARB_vertex_type_10f_11f_11f_rev](http://www.opengl.org/registry/specs/ARB/vertex_type_10f_11f_11f_rev.txt) |

While a number of features made it into core OpenGL, a number of  other features were left to specific extensions. These offer certainly  functionality that lesser 4.x hardware would be unable to handle.

Links:

- [OpenGL 4.4 Core Profile Specification](http://www.opengl.org/registry/doc/glspec44.core.pdf)
- [OpenGL 4.4 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec44.compatibility.pdf)
- [OpenGL Shading Language 4.40 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.40.pdf)

## OpenGL 4.3 (2012)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Debug messaging](https://www.khronos.org/opengl/wiki/Debug_Output) | [KHR_debug](http://www.opengl.org/registry/specs/KHR/debug.txt) |
| [GLSL multidimensional arrays](https://www.khronos.org/opengl/wiki/Arrays_Of_Arrays) | [ARB_arrays_of_arrays](http://www.opengl.org/registry/specs/ARB/arrays_of_arrays.txt) |
| [Clear Buffer Objects](https://www.khronos.org/opengl/wiki/Buffer_Clearing) to specific values, ala memset | [ARB_clear_buffer_object](http://www.opengl.org/registry/specs/ARB/clear_buffer_object.txt) |
| Arbitrary [Compute Shaders](https://www.khronos.org/opengl/wiki/Compute_Shader) | [ARB_compute_shader](http://www.opengl.org/registry/specs/ARB/compute_shader.txt) |
| [Arbitrary image copying](https://www.khronos.org/opengl/wiki/Copy_Texture) | [ARB_copy_image](http://www.opengl.org/registry/specs/ARB/copy_image.txt) |
| Compatibility with OpenGL ES 3.0                             | [ARB_ES3_compatibility](http://www.opengl.org/registry/specs/ARB/ES3_compatibility.txt) |
| Specifying [uniform locations in a shader](https://www.khronos.org/opengl/wiki/Layout_Uniform_Location) | [ARB_explicit_uniform_location](http://www.opengl.org/registry/specs/ARB/explicit_uniform_location.txt) |
| [Layer and viewport indices](https://www.khronos.org/opengl/wiki/Fragment_Shader#System_inputs) available from the fragment shader | [ARB_fragment_layer_viewport](http://www.opengl.org/registry/specs/ARB/fragment_layer_viewport.txt) |
| Rendering to a [Framebuffer Object](https://www.khronos.org/opengl/wiki/Framebuffer_Object) that [has no attachments](https://www.khronos.org/opengl/wiki/Empty_Framebuffer) | [ARB_framebuffer_no_attachments](http://www.opengl.org/registry/specs/ARB/framebuffer_no_attachments.txt) |
| [Generalized queries for information](https://www.khronos.org/opengl/wiki/Query_Image_Format) about [Image Formats](https://www.khronos.org/opengl/wiki/Image_Format) | [ARB_internalformat_query2](http://www.opengl.org/registry/specs/ARB/internalformat_query2.txt) |
| [Texture](https://www.khronos.org/opengl/wiki/Texture_Invalidation), [buffer object](https://www.khronos.org/opengl/wiki/Buffer_Invalidation), and [framebuffer](https://www.khronos.org/opengl/wiki/Framebuffer_Invalidation) invalidation. | [ARB_invalidate_subdata](http://www.opengl.org/registry/specs/ARB/invalidate_subdata.txt) |
| Issuing [multiple indirect rendering commands](https://www.khronos.org/opengl/wiki/Indirect_Drawing) from a single drawing command. | [ARB_multi_draw_indirect](http://www.opengl.org/registry/specs/ARB/multi_draw_indirect.txt) |
| Improved API for [getting info about program object interfaces](https://www.khronos.org/opengl/wiki/Program_Interface_Query) | [ARB_program_interface_query](http://www.opengl.org/registry/specs/ARB/program_interface_query.txt) |
| [Get size](https://www.khronos.org/opengl/wiki/Image_Load_Store#Image_size) of [images](https://www.khronos.org/opengl/wiki/Image_Load_Store) from GLSL | [ARB_shader_image_size](http://www.opengl.org/registry/specs/ARB/shader_image_size.txt) |
| [Buffer object read-write access from shader](https://www.khronos.org/opengl/wiki/Shader_Storage_Buffer_Object), via a uniform-block style mechanism | [ARB_shader_storage_buffer_object](http://www.opengl.org/registry/specs/ARB/shader_storage_buffer_object.txt) |
| [Accessing the stencil values from a depth/stencil texture](https://www.khronos.org/opengl/wiki/Stencil_Texturing) | [ARB_stencil_texturing](http://www.opengl.org/registry/specs/ARB/stencil_texturing.txt) |
| [Buffer Textures](https://www.khronos.org/opengl/wiki/Buffer_Texture) can now be [bound to a range of a buffer object](https://www.khronos.org/opengl/wiki/Buffer_Texture#Buffer_texture_range) rather than the whole thing | [ARB_texture_buffer_range](http://www.opengl.org/registry/specs/ARB/texture_buffer_range.txt) |
| GLSL can detect the available mipmap pyramid of a [sampler](https://www.khronos.org/opengl/wiki/Sampler_(GLSL)#Texture_mipmap_retrieval) or [image](https://www.khronos.org/opengl/wiki/Image_Load_Store#Image_mipmap) | [ARB_texture_query_levels](http://www.opengl.org/registry/specs/ARB/texture_query_levels.txt) |
| Immutable storage for [multisample textures](https://www.khronos.org/opengl/wiki/Immutable_Storage_Texture) | [ARB_texture_storage_multisample](http://www.opengl.org/registry/specs/ARB/texture_storage_multisample.txt) |
| [The ability to create a new texture](https://www.khronos.org/opengl/wiki/View_texture), with a new internal format, that references an existing texture's storage | [ARB_texture_view](http://www.opengl.org/registry/specs/ARB/texture_view.txt) |
| [Separation of vertex format from buffer object](https://www.khronos.org/opengl/wiki/Separate_Attribute_Format) | [ARB_vertex_attrib_binding](http://www.opengl.org/registry/specs/ARB/vertex_attrib_binding.txt) |
| Addition                                                     | Promoted from                                                |
| More robustness of API                                       | [ARB_robust_buffer_access_behavior](http://www.opengl.org/registry/specs/ARB/robust_buffer_access_behavior.txt), [ARB_robustness_isolation](http://www.opengl.org/registry/specs/ARB/robustness_isolation.txt), [WGL_ARB_robustness_isolation](http://www.opengl.org/registry/specs/ARB/wgl_robustness_isolation.txt), [GLX_ARB_robustness_isolation](http://www.opengl.org/registry/specs/ARB/glx_robustness_isolation.txt) |
| EAC and ETC compressed image formats.                        |                                                              |

Links:

- [OpenGL 4.3 Core Profile Specification](http://www.opengl.org/registry/doc/glspec43.core.20130214.pdf)
- [OpenGL 4.3 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec43.compatibility.20130214.pdf)
- [OpenGL Shading Language 4.30 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.30.8.pdf)

## OpenGL 4.2 (2011)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Allows atomically [incrementing/decrementing and fetching of buffer object memory locations from shaders](https://www.khronos.org/opengl/wiki/Atomic_Counter) | [ARB_shader_atomic_counters](http://www.opengl.org/registry/specs/ARB/shader_atomic_counters.txt) |
| Allows shaders to [read and write images](https://www.khronos.org/opengl/wiki/Image_Load_Store), with [few but difficult restrictions](https://www.khronos.org/opengl/wiki/Incoherent_Memory_Access) | [ARB_shader_image_load_store](http://www.opengl.org/registry/specs/ARB/shader_image_load_store.txt) |
| Allows texture objects to have [immutable storage, and allocating all mipmap levels and images in one call](https://www.khronos.org/opengl/wiki/Immutable_Storage_Texture). The storage becomes immutable, but the contents of the storage are not | [ARB_texture_storage](http://www.opengl.org/registry/specs/ARB/texture_storage.txt) |
| Allows [instanced rendering of data written by transform feedback operations](https://www.khronos.org/opengl/wiki/Draw_Transform_Feedback) | [ARB_transform_feedback_instanced](http://www.opengl.org/registry/specs/ARB/transform_feedback_instanced.txt) |
| Allows the setting of [Uniform Buffer Object](https://www.khronos.org/opengl/wiki/In-Shader_Uniform_Binding) and [sampler](https://www.khronos.org/opengl/wiki/In-Shader_Texture_Unit) binding points directly from GLSL, among [many other](https://www.khronos.org/opengl/wiki/Qualifier_Order) small changes | [ARB_shading_language_420pack](http://www.opengl.org/registry/specs/ARB/shading_language_420pack.txt) |
| Allows instanced rendering with a [starting instance value](https://www.khronos.org/opengl/wiki/Instancing). | [ARB_base_instance](http://www.opengl.org/registry/specs/ARB/base_instance.txt) |
| Allows the user to [detect the maximum number of samples possible](https://www.khronos.org/opengl/wiki/Query_Image_Format) for a particular [image format](https://www.khronos.org/opengl/wiki/Image_Format) and [texture type](https://www.khronos.org/opengl/wiki/Texture#Theory) | [ARB_internalformat_query](http://www.opengl.org/registry/specs/ARB/internalformat_query.txt) |
| Allows for sub-rectangle selection when transferring compressed texture data. | [ARB_compressed_texture_pixel_storage](http://www.opengl.org/registry/specs/ARB/compressed_texture_pixel_storage.txt) |
| Allows unpacking 16-bit floats from a 32-bit unsigned integer value in shaders. | [ARB_shading_language_packing](http://www.opengl.org/registry/specs/ARB/shading_language_packing.txt) |
| Allows querying of the [alignment for pointers](https://www.khronos.org/opengl/wiki/Buffer_Object#Alignment) returned from [buffer object mapping operations](https://www.khronos.org/opengl/wiki/Map_Buffer_Range) | [ARB_map_buffer_alignment](http://www.opengl.org/registry/specs/ARB/map_buffer_alignment.txt) |
| Allows explicitly defining how a [fragment shader will modify the depth value](https://www.khronos.org/opengl/wiki/Fragment_Shader_Output), so that the system can optimize these cases better | [ARB_conservative_depth](http://www.opengl.org/registry/specs/ARB/conservative_depth.txt) |
| Addition                                                     | Promoted from                                                |
| Allows the use of [BPTC compressed image formats](https://www.khronos.org/opengl/wiki/BPTC_Texture_Compression). | [ARB_texture_compression_BPTC](http://www.opengl.org/registry/specs/ARB/texture_compression_bptc.txt) |

Links:

- [OpenGL 4.2 Core Profile Specification](http://www.opengl.org/registry/doc/glspec42.core.20110808.pdf)
- [OpenGL 4.2 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec42.compatibility.20110808.pdf)
- [OpenGL Shading Language 4.20.6 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.20.6.clean.pdf)

## OpenGL 4.1 (2010)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| [Query and load a binary blob for program objects](https://www.khronos.org/opengl/wiki/Program_Binary) | [ARB_get_program_binary](http://www.opengl.org/registry/specs/ARB/get_program_binary.txt) |
| Ability to [bind programs individually to programmable stages](https://www.khronos.org/opengl/wiki/GLSL_Object#Program_separation) | [ARB_separate_shader_objects](http://www.opengl.org/registry/specs/ARB/separate_shader_objects.txt) |
| Pulling missing functionality from [OpenGL ES](https://www.khronos.org/opengl/wiki/OpenGL_ES) 2.0 into OpenGL | [ARB_ES2_compatibility](http://www.opengl.org/registry/specs/ARB/ES2_compatibility.txt) |
| Documents precision requirements for several FP operations   | [ARB_shader_precision](http://www.opengl.org/registry/specs/ARB/shader_precision.txt) |
| Provides [64-bit floating-point component vertex attributes](https://www.khronos.org/opengl/wiki/Vertex_Format) | [ARB_vertex_attrib_64_bit](http://www.opengl.org/registry/specs/ARB/vertex_attrib_64bit.txt) |
| Multiple [Viewports](https://www.khronos.org/opengl/wiki/Viewport) for the same rendering surface, or one per surface | [ARB_viewport_array](http://www.opengl.org/registry/specs/ARB/viewport_array.txt) |

Links:

- [OpenGL 4.1 Core Profile Specification](http://www.opengl.org/registry/doc/glspec41.core.20100725.pdf)
- [OpenGL 4.1 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec41.compatibility.20100725.pdf)
- [OpenGL Shading Language 4.10.6 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.10.6.clean.pdf)

## OpenGL 4.0 (2010)

| Addition                                                     | [Core Extension](https://www.khronos.org/opengl/wiki/Extension#Core_Extensions) |
| ------------------------------------------------------------ | ------------------------------------------------------------ |
| Shading language 4.00                                        | [ARB_texture_query_lod](http://www.opengl.org/registry/specs/ARB/texture_query_lod.txt), [ARB_gpu_shader5](http://www.opengl.org/registry/specs/ARB/gpu_shader5.txt), [ARB_gpu_shader_fp64](http://www.opengl.org/registry/specs/ARB/gpu_shader_fp64.txt), [ARB_shader_subroutine](http://www.opengl.org/registry/specs/ARB/shader_subroutine.txt), [ARB_texture_gather](http://www.opengl.org/registry/specs/ARB/texture_gather.txt) |
| [Indirect Drawing](https://www.khronos.org/opengl/wiki/Indirect_Drawing), without multidraw | [ARB_draw_indirect](http://www.opengl.org/registry/specs/ARB/draw_indirect.txt) |
| Request minimum number of fragment inputs                    | [ARB_sample_shading](http://www.opengl.org/registry/specs/ARB/sample_shading.txt) |
| [Tessellation](https://www.khronos.org/opengl/wiki/Tessellation), with shader stages | [ARB_tessellation_shader](http://www.opengl.org/registry/specs/ARB/tessellation_shader.txt) |
| [Buffer Texture](https://www.khronos.org/opengl/wiki/Buffer_Texture) formats RGB32F, RGB32I, RGB32UI | [ARB_texture_buffer_object_rgb32](http://www.opengl.org/registry/specs/ARB/texture_buffer_object_rgb32.txt) |
| [Cubemap Array Texture](https://www.khronos.org/opengl/wiki/Cubemap_Array_Texture) | [ARB_texture_cube_map_array](http://www.opengl.org/registry/specs/ARB/texture_cube_map_array.txt) |
| [Transform Feedback](https://www.khronos.org/opengl/wiki/Transform_Feedback) objects and multiple feedback stream output. | [ARB_transform_feedback2](http://www.opengl.org/registry/specs/ARB/transform_feedback2.txt), [ARB_transform_feedback3](http://www.opengl.org/registry/specs/ARB/transform_feedback3.txt) |
| Addition                                                     | Promoted from                                                |
| [Individual blend equations for each color output](https://www.khronos.org/opengl/wiki/Draw_Buffer_Blend) | [ARB_draw_buffers_blend](http://www.opengl.org/registry/specs/ARB/draw_buffers_blend.txt) |

Links:

- [OpenGL 4.0 Core Profile Specification](http://www.opengl.org/registry/doc/glspec40.core.20100311.pdf)
- [OpenGL 4.0 Compatibility Profile Specification](http://www.opengl.org/registry/doc/glspec40.compatibility.20100311.pdf)
- [OpenGL Shading Language 4.00.9 Specification](http://www.opengl.org/registry/doc/GLSLangSpec.4.00.9.clean.pdf)



## 参考

- [History of OpenGL](https://www.khronos.org/opengl/wiki/History_of_OpenGL)
- [OpenGL4.6规范](https://www.khronos.org/registry/OpenGL/specs/gl/glspec46.compatibility.withchanges.pdf)
