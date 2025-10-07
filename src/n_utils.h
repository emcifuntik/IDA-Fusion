#pragma once

namespace n_utils{
  inline i32 get_insn_imm_offset(insn_t* insn){
    for(u32 i = 0; i < UA_MAXOP; i++){
      op_t* op = &insn->ops[i];

      // Instruction contains invalid operand/opcode
      if(op->type == o_void)
        return 0;

      // Instruction contains relocated address
      if(op->offb > 0)
        return op->offb;
    }

    return 0;
  }

  inline void get_text_min_max(ea_t& ea_min, ea_t& ea_max){
    ea_min = inf_get_min_ea();
    ea_max = inf_get_max_ea();
  }

  inline void copy_to_clipboard(i8* buffer){
#ifdef __NT__
    // Windows implementation
    size_t len = strlen(buffer) + 1;
    HGLOBAL hMem = GlobalAlloc(GMEM_MOVEABLE, len);
    if(hMem){
      memcpy(GlobalLock(hMem), buffer, len);
      GlobalUnlock(hMem);
      if(OpenClipboard(nullptr)){
        EmptyClipboard();
        SetClipboardData(CF_TEXT, hMem);
        CloseClipboard();
      }
    }
#elif defined(__LINUX__)
    // Linux: Use xclip or xsel if available, otherwise just print
    qstring cmd;
    cmd.sprnt("echo '%s' | xclip -selection clipboard 2>/dev/null || echo '%s' | xsel --clipboard 2>/dev/null || true", buffer, buffer);
    system(cmd.c_str());
#elif defined(__MAC__)
    // macOS: Use pbcopy
    FILE* pipe = popen("pbcopy", "w");
    if(pipe){
      fwrite(buffer, 1, strlen(buffer), pipe);
      pclose(pipe);
    }
#endif
  }

  inline std::string format(const i8* fmt, ...) {
    i8 buffer[1024];
  
    va_list args;
    va_start(args, fmt);
    vsnprintf(buffer, 1024, fmt, args);
    va_end(args);
  
    return std::string(buffer);
  }
};