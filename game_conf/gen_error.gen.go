

 




// ============================================================================
// 本代码由xlsx工具自动生成，请勿手动修改
// Config: ConstGlobalConfig
// ============================================================================

package const

import (
	"sync/atomic"

	"github.com/Iori372552686/GoOne/module/gamedata"
	protocol "github.com/Iori372552686/g1_common/protocol"
	"github.com/golang/protobuf/proto"
)

// ---------------------------------------------------------------------------
//  内部数据（不可变快照）
// ---------------------------------------------------------------------------

type snapshot struct {         
	list []*protocol.ConstGlobalConfig
}

var ptr atomic.Pointer[snapshot]

func load() *snapshot {
	return ptr.Load()
}

// ---------------------------------------------------------------------------
//  注册 & 加载
// ---------------------------------------------------------------------------

func init() {
	gamedata.Register("ConstGlobalConfig", parse)
}

func parse(buf string) error {
	data := &protocol.ConstGlobalConfigAry{}
	if err := proto.UnmarshalText(buf, data); err != nil {
		return err
	}

	s := &snapshot{
		list: data.Ary,
	}


	ptr.Store(s)
	return nil
}

// ---------------------------------------------------------------------------
//  基础查询
// ---------------------------------------------------------------------------


// GetHead 返回第一条记录，无数据时返回 nil
func GetHead() *protocol.ConstGlobalConfig {
	s := load()
	if s == nil || len(s.list) == 0 {
		return nil
	}
	return s.list[0]
}

// GetAll 返回全部记录的拷贝切片
func GetAll() []*protocol.ConstGlobalConfig {
	s := load()
	if s == nil {
		return nil
	}
	out := make([]*protocol.ConstGlobalConfig, len(s.list))
	copy(out, s.list)
	return out
}

// Count 返回记录总数
func Count() int {
	s := load()
	if s == nil {
		return 0
	}
	return len(s.list)
}

// ---------------------------------------------------------------------------
//  遍历
// ---------------------------------------------------------------------------

// Range 遍历所有记录，fn 返回 false 时提前终止
func Range(fn func(*protocol.ConstGlobalConfig) bool) {
	s := load()
	if s == nil {
		return
	}
	for _, item := range s.list {
		if !fn(item) {
			return
		}
	}
}

// ---------------------------------------------------------------------------
//  条件查询
// ---------------------------------------------------------------------------

// Find 返回第一个满足条件的记录，无匹配返回 nil
func Find(fn func(*protocol.ConstGlobalConfig) bool) *protocol.ConstGlobalConfig {
	s := load()
	if s == nil {
		return nil
	}
	for _, item := range s.list {
		if fn(item) {
			return item
		}
	}
	return nil
}

// Filter 返回所有满足条件的记录
func Filter(fn func(*protocol.ConstGlobalConfig) bool) []*protocol.ConstGlobalConfig {
	s := load()
	if s == nil {
		return nil
	}
	var out []*protocol.ConstGlobalConfig
	for _, item := range s.list {
		if fn(item) {
			out = append(out, item)
		}
	}
	return out
}

// ---------------------------------------------------------------------------
//  索引查询
// ---------------------------------------------------------------------------
